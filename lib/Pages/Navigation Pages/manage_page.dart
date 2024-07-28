import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Pages/Core%20Pages/work_detail_page.dart';
import 'package:cryptel007/Tools/dialog_box.dart';
import 'package:flutter/material.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  _ManagePageState createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Manage Works',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.grey[200],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('work').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final workData = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 5,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    workData['WorkTitle'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Work Order Number: ${workData['workOrderNumber'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      if (workData['password'] != null && workData['workOrderNumber'] != null) {
                        _showPasswordDialog(workData['password'], workData['workOrderNumber']);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password or work order number is null')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showPasswordDialog(String password, String workOrderNumber) {
    final TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_passwordController.text == password) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkDetailPage(workOrderNumber: workOrderNumber),
                    ),
                  );
                } else {
                  DialogBox.show(
                    context,
                    title: 'Invalid Password',
                    content: 'The password you entered is incorrect. Please try again.',
                    cancelButtonText: 'Cancel',
                    confirmButtonText: 'OK',
                    confirmButtonColor: Colors.red,
                    onConfirm: () {
                      Navigator.pop(context);
                    },
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
