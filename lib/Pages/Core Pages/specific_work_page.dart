
import 'package:cryptel007/Pages/Core%20Pages/materials_page.dart';
import 'package:cryptel007/Pages/Core%20Pages/specific_work_edit_page.dart';
import 'package:cryptel007/Pages/Core%20Pages/work_detail_page.dart';
import 'package:cryptel007/Pages/Core%20Pages/add_specific_work_dialog.dart';
import 'package:cryptel007/Pages/Seperated%20Class/photo_view_screen.dart';
import 'package:cryptel007/Pages/Seperated%20Class/work_card.dart';
import 'package:cryptel007/tools/user_role_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

class SpecificWorkPage extends StatefulWidget {
  final String workOrderNumber;
  const SpecificWorkPage({super.key, required this.workOrderNumber});

  @override
  _SpecificWorkPageState createState() => _SpecificWorkPageState();
}

class _SpecificWorkPageState extends State<SpecificWorkPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserRoleService _userRoleService = UserRoleService();
  GoogleSignInAccount? _currentUser;
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
        _isLoading = true;
      });
      _fetchUserRole(account?.email);
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

  void _showAddWorkDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AddWorkDialogContent(workOrderNumber: widget.workOrderNumber);
      },
    );
  }

  void _navigateToEditPage(String workId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpecificWorkEditPage(
          workOrderNumber: widget.workOrderNumber,
          workId: workId,
        ),
      ),
    );
  }
    void _navigateToMaterialPage(String workId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusPage(
          workOrderNumber: widget.workOrderNumber,
          specificWorkId: workId,
        ),
      ),
    );
  }

  void _viewImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewScreen(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('assets/arrow.png'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WorkDetailPage(workOrderNumber: widget.workOrderNumber),
              ),
            );
          },
        ),
        title: Text(
          'Work Status',
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_userRole == 'ADMIN' || _userRole == 'Manager' || _userRole == 'Editor')
            IconButton(icon: Image.asset('assets/add.png'), onPressed: _showAddWorkDialog),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('works')
                  .doc(widget.workOrderNumber)
                  .collection('specificWorks')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final data = snapshot.data?.docs ?? [];

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final doc = data[index];
                    return WorkCard(
                      doc: doc,
                      onEdit: () => _navigateToEditPage(doc['id']),
                      onTaap: () => _navigateToMaterialPage(doc['id']),
                      onViewImage: () => _viewImage(doc['imageUrl']),
                      itemNumber: index + 1,
                    );
                  },
                );
              },
            ),
    );
  }
}
