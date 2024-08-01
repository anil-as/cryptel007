import 'package:cryptel007/Pages/Core%20Pages/add_work_page.dart';
import 'package:cryptel007/Pages/Navigation%20Pages/settings_page.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  String? _userRole;
  bool _isProfileExpanded = false;
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

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();
      if (mounted) {
        setState(() {
          _userRole = userDoc['role'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user role: $e')),
      );
    }
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Access Denied',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Only authorized users have access to this section.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListTileTheme(
        textColor: Colors.white,
        iconColor: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 128.0,
              height: 128.0,
              margin: const EdgeInsets.only(
                top: 24.0,
                bottom: 24.0,
              ),
              child: Center(
                child: Image.asset(
                  'assets/logobluer.png',
                  width: 100.0,
                  height: 100.0,
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: _currentUser?.photoUrl != null && _currentUser!.photoUrl!.isNotEmpty
                          ? NetworkImage(_currentUser!.photoUrl!)
                          : const AssetImage('assets/profileimg.png') as ImageProvider,
                    ),
                    title: Text(
                      _currentUser?.displayName ?? '',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser?.email ?? '',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              _userRole ?? '',
                              style: const TextStyle(fontSize: 16, color: AppColors.logoblue),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              onTap: () {
                if (_userRole == 'ADMIN' || _userRole == 'Manager' || _userRole == 'Editor') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddWorkPage()), // Ensure AddWorkPage is defined
                  );
                } else {
                  _showAccessDeniedDialog();
                }
              },
              leading: const FaIcon(FontAwesomeIcons.barsProgress),
              title: const Text('Work'),
              trailing: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            ListTile(
              onTap: () {},
              leading: const FaIcon(FontAwesomeIcons.gears),
              title: const Text('Admin'),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              leading: const FaIcon(FontAwesomeIcons.bookBookmark),
              title: const Text('Saved'),
            ),
            ListTile(
              onTap: () {},
              leading: const FaIcon(FontAwesomeIcons.rightFromBracket),
              title: const Text('Logout'),
            ),
            const Spacer(),
            const DefaultTextStyle(
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Terms of Service | Privacy Policy'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
