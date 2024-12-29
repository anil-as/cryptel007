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
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(email).get();

      if (userDoc.exists) {
        setState(() {
          _userRole = userDoc['role'];
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
    {"title": "AGEING", "status": "Not Started"},
    {"title": "H.T", "status": "Not Started"},
    {"title": "FINISH TURNING", "status": "Not Started"},
    {"title": "FINISH MILLING", "status": "Not Started"},
    {"title": "EDM", "status": "Not Started"},
    {"title": "WIRE CUT", "status": "Not Started"},
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
    'Not Required',
  ];

  // Assign colors for each status
  Map<String, Color> statusColors = {
    'Not Started': Colors.grey,
    'Progressing': Colors.blue,
    'On Hold': Colors.orangeAccent,
    'Completed': Colors.green,
    'Not Required': Colors.red,
  };

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _saveTaskStatus(String taskTitle, String status) async {
    try {
      await firestore
          .collection('works')
          .doc(widget.workOrderNumber)
          .collection('specificWorks')
          .doc(widget.specificWorkId)
          .collection('tasks')
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

  Stream<QuerySnapshot> _getTasksStream() {
    return firestore
        .collection('works')
        .doc(widget.workOrderNumber)
        .collection('specificWorks')
        .doc(widget.specificWorkId)
        .collection('tasks')
        .snapshots();
  }

  List<Map<String, dynamic>> _mergeTasks(List<DocumentSnapshot> firestoreTasks) {
    Map<String, String> firestoreTaskMap = {
      for (var task in firestoreTasks)
        (task.data() as Map<String, dynamic>)['title']: (task.data() as Map<String, dynamic>)['status']
    };

    return tasks.map((localTask) {
      return {
        'title': localTask['title'],
        'status': firestoreTaskMap[localTask['title']] ?? localTask['status'],
      };
    }).toList();
  }

  bool _canChangeStatus() {
    return _userRole == 'ADMIN' || _userRole == 'Editor' || _userRole == 'Manager';
  }

  bool _shouldShowTask(String status) {
    // If the status is 'Not Required' and the user does not have the required role, hide the task
    if (status == 'Not Required') {
      return _canChangeStatus();
    }
    return true;
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

          List<DocumentSnapshot> firestoreTasks = snapshot.data!.docs;
          List<Map<String, dynamic>> mergedTasks = _mergeTasks(firestoreTasks);

          return ListView.builder(
            itemCount: mergedTasks.length,
            itemBuilder: (context, index) {
              String taskTitle = mergedTasks[index]['title'];
              String taskStatus = mergedTasks[index]['status'];

              if (!_shouldShowTask(taskStatus)) return SizedBox.shrink();

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
                              _saveTaskStatus(taskTitle, newValue);
                            }
                          },
                          items: statuses.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: statusColors[value],
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      : Text(
                          taskStatus,
                          style: TextStyle(
                            fontSize: 18,
                            color: statusColors[taskStatus],
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
