import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Pages/Core%20Pages/work_detail_page.dart';
import 'package:cryptel007/Pages/Navigation%20Pages/home_page.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

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

  Future<void> _removeBookmark(String email, String workOrderNumber) async {
    try {
      await _firestore
          .collection('users')
          .doc(email)
          .collection('bookmarks')
          .doc(workOrderNumber)
          .delete();
      setState(() {
        _bookmarkedWorks.removeWhere(
            (doc) => (doc.data() as Map<String, dynamic>)['workOrderNumber'] == workOrderNumber);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark removed successfully')),
      );
    } catch (e) {
      print('Error removing bookmark: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove bookmark')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('assets/arrow.png'),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        title: const Text('Saved'),
        backgroundColor: AppColors.lightGrey,
        elevation: 0,
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
              : CarouselSlider.builder(
                  itemCount: _bookmarkedWorks.length,
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * 0.85,
                    autoPlay: false,
                    enlargeCenterPage: true,
                    aspectRatio: 2.0,
                    viewportFraction: 0.9,
                  ),
                  itemBuilder: (context, index, realIdx) {
                    final doc = _bookmarkedWorks[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final workOrderNumber = data['workOrderNumber'];

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _fetchWorkDetails(workOrderNumber),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
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
                        final createdDate = workDetails?['CDATE'] != null
                            ? (workDetails!['CDATE'] as Timestamp).toDate()
                            : null;

                        final formattedDate = createdDate != null
                            ? DateFormat('dd MMM yyyy').format(createdDate)
                            : 'N/A';

                        return Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Work Order: $workOrderNumber',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Title: ${workDetails?['WORKTITLE'] ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Customer: ${workDetails?['CUSTOMERNAME'] ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Created Date: $formattedDate',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (workDetails?['PHOTO'] != null)
                                Expanded(
                                  child: Image.network(
                                    workDetails!['PHOTO'],
                                    width: double.infinity,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton.icon(
                                    onPressed: () async {
                                      final GoogleSignInAccount? user =
                                          _googleSignIn.currentUser;
                                      if (user != null) {
                                        await _removeBookmark(
                                            user.email!, workOrderNumber);
                                      }
                                    },
                                    icon: const Icon(Icons.star_outline),
                                    label: const Text('Unstar'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WorkDetailPage(
                                            workOrderNumber: workOrderNumber,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.details),
                                    label: const Text('Details'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
