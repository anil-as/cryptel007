import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Pages/Core%20Pages/work_detail_page.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:flutter/material.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  _ManagePageState createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, bool> _isPasswordVisible = {};
  final Map<String, bool> _isPasswordObscure = {};
  final Map<String, TextEditingController> _passwordControllers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Manage',
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

          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final workData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                final workOrderNumber = workData['workOrderNumber'];

                if (!_isPasswordVisible.containsKey(workOrderNumber)) {
                  _isPasswordVisible[workOrderNumber] = false;
                  _isPasswordObscure[workOrderNumber] = true;
                  _passwordControllers[workOrderNumber] =
                      TextEditingController();
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPasswordVisible[workOrderNumber] =
                          !_isPasswordVisible[workOrderNumber]!;
                    });
                  },
                  child: Column(
                    children: [
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: const BorderSide(
                            color: AppColors.logoblue,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: ListTile(
                            iconColor: AppColors.logoblue,
                            tileColor: Colors.white,
                            title: Text(
                              (workData['WorkTitle'] ?? '').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Work Order Number: $workOrderNumber',
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox(),
                        secondChild: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextField(
                            controller: _passwordControllers[workOrderNumber],
                            obscureText:
                                (_isPasswordObscure[workOrderNumber] ?? true)!,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              border: const OutlineInputBorder(),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                        _isPasswordObscure[workOrderNumber]!
                                            ? Icons.visibility_off
                                            : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordObscure[workOrderNumber] =
                                            !_isPasswordObscure[
                                                workOrderNumber]!;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward),
                                    onPressed: () async {
                                      final password =
                                          _passwordControllers[workOrderNumber]!
                                              .text;
                                      final docRef = _firestore
                                          .collection('work')
                                          .doc(workOrderNumber);
                                      final doc = await docRef.get();
                                      if (doc.exists) {
                                        final data =
                                            doc.data() as Map<String, dynamic>;
                                        if (password == data['password']) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  WorkDetailPage(
                                                workOrderNumber:
                                                    workOrderNumber,
                                              ),
                                            ),
                                          );
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Authentication Failed'),
                                                content: Text.rich(
                                                  TextSpan(
                                                    text:
                                                        'The password you entered is incorrect for ',
                                                    children: [
                                                      TextSpan(
                                                        text: workData[
                                                            'WorkTitle'],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const TextSpan(
                                                          text:
                                                              '. Please try again.'),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: const Text('OK'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Work order not found'),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        crossFadeState: _isPasswordVisible[workOrderNumber]!
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
