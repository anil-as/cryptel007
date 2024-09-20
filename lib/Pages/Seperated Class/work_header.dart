import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:cryptel007/Tools/edit_detailsdialog_box.dart';
import 'package:cryptel007/Tools/edit_photo_page.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class WorkHeader extends StatefulWidget {
  final Map<String, dynamic> data;

  final String? workTitle;
  final String? workPhoto;
  final Timestamp? cdate;
  final String? customerName;
  final double screenWidth;
  final double textScaleFactor;
  final String workOrderNumber;

  const WorkHeader({
    super.key,
    this.workTitle,
    this.workPhoto,
    this.cdate,
    this.customerName,
    required this.workOrderNumber,
    required this.data,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  State<WorkHeader> createState() => _WorkHeaderState();
}

class _WorkHeaderState extends State<WorkHeader> {
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
          _userRole = userDoc[
              'role']; // Assuming 'role' is a field in your Firestore user document
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user role: $e')),
      );
    }
  }

  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.all(widget.screenWidth * 0.04),
            decoration: BoxDecoration(
              color: AppColors.logoblue,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/whitelogo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.workTitle?.toUpperCase() ??
                                'NO TITLE AVAILABLE',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (widget.cdate != null)
                            Text(
                              DateFormat('MMMM dd, yyyy - hh:mm a')
                                  .format(widget.cdate!.toDate()),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          if (widget.customerName != null)
                            Container(
                              margin: const EdgeInsets.only(top: 8.0),
                              padding: EdgeInsets.symmetric(
                                  horizontal: widget.screenWidth * 0.02,
                                  vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                widget.customerName!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14 * widget.textScaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_userRole == 'ADMIN' ||
                            _userRole == 'Editor' ||
                            _userRole == 'Manager') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditPhotoPage(
                                workOrderNumber: widget.workOrderNumber,
                              ),
                            ),
                          );
                        } else {
                          // Optionally, show a message or handle non-admin users
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Access denied. Admins only.'),
                            ),
                          );
                        }
                      },
                      child: ClipOval(
                        child: widget.workPhoto != null
                            ? Image.network(
                                widget.workPhoto!,
                                width: 70.0,
                                height: 70.0,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.photo,
                                size: 100.0,
                                color: Colors.grey[600],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_userRole == 'ADMIN')
          Positioned(
            bottom: widget.screenWidth * 0.04,
            right: widget.screenWidth * 0.04,
            child: GestureDetector(
                onTap: () => _showEditDialog(context),
                child: Image.asset(
                  'assets/edit.png',
                  width: 24,
                  height: 14,
                  color: Colors.white,
                )),
          ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDetailsDialog(
          data: widget.data,
          workOrderNumber: widget.workOrderNumber,
        );
      },
    );
  }
}
