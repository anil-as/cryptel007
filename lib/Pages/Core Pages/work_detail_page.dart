import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Pages/Core%20Pages/specific_work_page.dart';
import 'package:cryptel007/Pages/Navigation%20Pages/home_page.dart';
import 'package:cryptel007/Pages/Seperated%20Class/details_container.dart';
import 'package:cryptel007/Pages/Seperated%20Class/work_header.dart';
import 'package:cryptel007/Pages/Sub%20Pages/certification_page.dart';
import 'package:cryptel007/Pages/Sub%20Pages/drawings_page.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:cryptel007/Tools/custom_button.dart';
import 'package:cryptel007/Tools/user_role_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class WorkDetailPage extends StatefulWidget {
  final String workOrderNumber;

  const WorkDetailPage({super.key, required this.workOrderNumber});

  @override
  _WorkDetailPageState createState() => _WorkDetailPageState();
}

class _WorkDetailPageState extends State<WorkDetailPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserRoleService _userRoleService = UserRoleService();
  String? _userRole;
  bool _isLoading = true;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _isLoading = true;
      });
      _fetchUserRole(account?.email);
      _checkIfBookmarked(account?.email);
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _fetchUserRole(String? email) async {
    if (email == null) return;

    final role = await _userRoleService.fetchUserRole(email);

    if (mounted) {
      setState(() {
        _userRole = role;
        _isLoading = false;
      });
    }
  }

  Future<void> _checkIfBookmarked(String? email) async {
    if (email == null) return;

    final bookmarksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('bookmarks')
        .doc(widget.workOrderNumber);

    final doc = await bookmarksRef.get();

    if (mounted) {
      setState(() {
        _isBookmarked = doc.exists;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final userEmail = _googleSignIn.currentUser?.email;
    if (userEmail == null) return;

    final bookmarksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('bookmarks')
        .doc(widget.workOrderNumber);

    if (_isBookmarked) {
      await bookmarksRef.delete();
    } else {
      await bookmarksRef.set({
        'workOrderNumber': widget.workOrderNumber,
        // Add other relevant fields if necessary
      });
    }

    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textScaleFactor = mediaQuery.textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Work Details',
          style: TextStyle(fontSize: 20 * textScaleFactor),
        ),
        leading: IconButton(
          icon: Image.asset('assets/arrow.png'),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: _isBookmarked
                ? Image.asset('assets/bookmarkplus.png', width: 40, height: 40)
                : Image.asset('assets/bookmarknormal.png',
                    width: 37, height: 37),
            onPressed: _toggleBookmark,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('works')
                        .doc(widget.workOrderNumber)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(
                            child:
                                Text('No details found for this work order.'));
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WorkHeader(
                            workOrderNumber: data['WONUMBER'],
                            data: data,
                            workTitle: data['WORKTITLE'],
                            workPhoto: data['PHOTO'],
                            cdate: data['CDATE'],
                            customerName: data['CUSTOMERNAME'],
                            screenWidth: screenWidth,
                            textScaleFactor: textScaleFactor,
                          ),
                          Container(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            child: DetailsContainer(
                              data: data,
                              screenWidth: screenWidth,
                              textScaleFactor: textScaleFactor,
                              userRole: _userRole.toString(),
                              workOrderNumber: data['WONUMBER'],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04),
                            child: Column(
                              children: [
                                CustomButton(
                                  text: 'Work Status',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SpecificWorkPage(
                                                workOrderNumber:
                                                    data['WONUMBER'],
                                              )),
                                    );
                                  },
                                  h: 47,
                                  w: double.infinity,
                                  buttonColor: Colors.yellow,
                                  textColor: Colors.black,
                                ),
                                SizedBox(height: screenWidth * 0.02),
                                CustomButton(
                                  text: 'Certification',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CertificationPage(
                                                workOrderNumber:
                                                    data['WONUMBER'],
                                              )),
                                    );
                                  },
                                  h: 47,
                                  w: double.infinity,
                                  buttonColor: AppColors.lightblue,
                                  textColor: Colors.black,
                                ),
                                SizedBox(height: screenWidth * 0.02),
                                if (_userRole == 'ADMIN' ||
                                    _userRole == 'Manager' ||
                                    _userRole == 'Editor')
                                  CustomButton(
                                    text: 'Drawings',
                                    onPressed: () {
                                        Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DrawingsPage(
                                                workOrderNumber:
                                                    data['WONUMBER'],
                                              )),
                                    );
                                    },
                                    h: 47,
                                    w: double.infinity,
                                    buttonColor: AppColors.accentText,
                                    textColor: Colors.white,
                                  ),
                                SizedBox(height: screenWidth * 0.02),
                                if (_userRole == 'ADMIN' ||
                                    _userRole == 'Manager' ||
                                    _userRole == 'Editor')
                                  CustomButton(
                                    text: 'Button 4',
                                    onPressed: () {
                                      // Handle button 4 action
                                    },
                                    h: 47,
                                    w: double.infinity,
                                    buttonColor: AppColors.logoblue,
                                    textColor: Colors.white,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
