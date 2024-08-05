import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Pages/Core%20Pages/work_detail_page.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<DocumentSnapshot> _bookmarkedWorks = [];

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      if (account != null) {
        _fetchBookmarkedWorks(account.email);
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _fetchBookmarkedWorks(String? email) async {
    if (email == null) return;

    final bookmarksRef =
        _firestore.collection('users').doc(email).collection('bookmarks');

    final snapshot = await bookmarksRef.get();

    if (mounted) {
      setState(() {
        _bookmarkedWorks = snapshot.docs;
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchWorkDetails(
      String workOrderNumber) async {
    try {
      final workRef = _firestore.collection('works').doc(workOrderNumber);
      final snapshot = await workRef.get();
      return snapshot.data();
    } catch (e) {
      print('Error fetching work details: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text('Saved'),
        backgroundColor: AppColors.lightGrey,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarkedWorks.isEmpty
              ? const Center(
                  child: Text(
                    'Nothing Saved',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _bookmarkedWorks.length,
                  itemBuilder: (context, index) {
                    final doc = _bookmarkedWorks[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final workOrderNumber = data['workOrderNumber'];

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _fetchWorkDetails(workOrderNumber),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Card(
                            elevation: 4,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Card(
                            elevation: 4,
                            child: Center(child: Text('Error loading details')),
                          );
                        }

                        final workDetails = snapshot.data;

                        return Card(
                          elevation: 0,
                          color: Colors.white, // Set your desired color here
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkDetailPage(
                                    workOrderNumber: workOrderNumber,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Work Order: $workOrderNumber',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.logoblue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Title: ${workDetails?['WORKTITLE'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Customer: ${workDetails?['CUSTOMERNAME'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Align(
                                    alignment: Alignment.bottomRight,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.logoblue,
                                      size: 20,
                                    ),
                                  ),
                                ],
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
