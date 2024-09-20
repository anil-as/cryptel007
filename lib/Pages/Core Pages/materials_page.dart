import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class StatusPage extends StatefulWidget {
  final String workOrderNumber;
  final String specificWorkId;

  const StatusPage({
    super.key,
    required this.workOrderNumber,
    required this.specificWorkId,
  });

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _fetchUserRole(account?.email);
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _fetchUserRole(String? email) async {
    if (email == null) return;

    try {
      // Fetch the user role from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(email).get();

      if (userDoc.exists) {
        setState(() {
          _userRole = userDoc['role']; // Assuming 'role' is a field in your Firestore user document
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user role: $e')),
      );
    }
  }

  // Full list of tasks with default status "Not Started"
  List<Map<String, dynamic>> tasks = [
    {"title": "METALCUTTING", "status": "Not Started"},
    {"title": "ROUGHING", "status": "Not Started"},
    {"title": "H.T", "status": "Not Started"},
    {"title": "FINISH TURNING", "status": "Not Started"},
    {"title": "FINISH MILLING", "status": "Not Started"},
    {"title": "EDM", "status": "Not Started"},
    {"title": "FITTING", "status": "Not Started"},
    {"title": "INSPECTION", "status": "Not Started"},
    {"title": "CUSTOMER INSPECTION", "status": "Not Started"},
    {"title": "SURFACE TREATMENT", "status": "Not Started"},
    {"title": "VISUAL INSPECTION", "status": "Not Started"},
    {"title": "DELIVERY", "status": "Not Started"},
  ];

  // List of possible statuses
  List<String> statuses = [
    'Not Started',
    'Progressing',
    'On Hold',
    'Completed',
  ];

  // Assign colors for each status
  Map<String, Color> statusColors = {
    'Not Started': Colors.grey,
    'Progressing': Colors.green,
    'On Hold': Colors.yellow,
    'Completed': Colors.blue,
  };

  // Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Method to save the status of a task to Firestore
  Future<void> _saveTaskStatus(String taskTitle, String status) async {
    try {
      await firestore
          .collection('works')
          .doc(widget.workOrderNumber)
          .collection('specificWorks')
          .doc(widget.specificWorkId)
          .collection('tasks') // Subcollection for each task's status
          .doc(taskTitle)
          .set({
        'title': taskTitle,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving task status: $e");
    }
  }

  // Stream to get real-time data from Firestore
  Stream<QuerySnapshot> _getTasksStream() {
    return firestore
        .collection('works')
        .doc(widget.workOrderNumber)
        .collection('specificWorks')
        .doc(widget.specificWorkId)
        .collection('tasks')
        .snapshots();
  }

  // Merge Firestore data with local task list
  List<Map<String, dynamic>> _mergeTasks(List<DocumentSnapshot> firestoreTasks) {
    // Create a map from Firestore tasks
    Map<String, String> firestoreTaskMap = {
      for (var task in firestoreTasks)
        (task.data() as Map<String, dynamic>)['title']: (task.data() as Map<String, dynamic>)['status']
    };

    // Update the local tasks list with Firestore data
    return tasks.map((localTask) {
      return {
        'title': localTask['title'],
        'status': firestoreTaskMap[localTask['title']] ?? localTask['status'], // Use Firestore status if available
      };
    }).toList();
  }

  // Check if the user has permission to change status
  bool _canChangeStatus() {
    return _userRole == 'ADMIN' || _userRole == 'Editor' || _userRole == 'Manager';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Status List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No tasks available'));
          }

          // List of tasks fetched from Firestore
          List<DocumentSnapshot> firestoreTasks = snapshot.data!.docs;

          // Merge Firestore tasks with local tasks
          List<Map<String, dynamic>> mergedTasks = _mergeTasks(firestoreTasks);

          return ListView.builder(
            itemCount: mergedTasks.length,
            itemBuilder: (context, index) {
              // Extracting task title and status
              String taskTitle = mergedTasks[index]['title'];
              String taskStatus = mergedTasks[index]['status'];

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(taskTitle),
                  trailing: _canChangeStatus()
                      ? DropdownButton<String>(
                          value: taskStatus,
                          dropdownColor: Colors.white,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _saveTaskStatus(taskTitle, newValue); // Save new status
                            }
                          },
                          items: statuses.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: statusColors[value], // Color the text
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      : Text(
                          taskStatus,
                          style: TextStyle(
                            color: statusColors[taskStatus], // Display status in appropriate color
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
