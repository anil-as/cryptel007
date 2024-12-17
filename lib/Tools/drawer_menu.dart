// lib/pages/navigation_pages/drawer_menu.dart

import 'package:cryptel007/Pages/Core%20Pages/add_work_page.dart';
import 'package:cryptel007/Pages/Core%20Pages/login_page.dart';
import 'package:cryptel007/Pages/Sub%20Pages/about_page.dart';
import 'package:cryptel007/Pages/Sub%20Pages/admin_page.dart';
import 'package:cryptel007/Pages/Sub%20Pages/bookmark_page.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:cryptel007/Tools/user_role_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
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

  Future<void> logout() async {
    await _googleSignIn.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: ListTileTheme(
          textColor: Colors.white,
          iconColor: Colors.white,
          child: Column(
            children: [
              SizedBox(
                width: 148.0,
                height: 148.0,
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
                  padding: const EdgeInsets.only(bottom: 17, left: 7, right: 7),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: _currentUser?.photoUrl != null &&
                                _currentUser!.photoUrl!.isNotEmpty
                            ? NetworkImage(_currentUser!.photoUrl!)
                            : const AssetImage('assets/profileimg.png')
                                as ImageProvider,
                      ),
                      title: Text(
                        _currentUser?.displayName ?? '',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser?.email ?? '',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          if (_userRole != 'USER')
                            _isLoading
                                ? const CircularProgressIndicator()
                                : Text(
                                    _userRole ?? '',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.logoblue),
                                  ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              if (_userRole == 'ADMIN' ||
                  _userRole == 'Manager' ||
                  _userRole == 'Editor')
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddWorkPage()),
                    );
                  },
                  leading: Image.asset(
                    'assets/project.png',
                    width: 34,
                    height: 34,
                  ),
                  title: const Text(
                    'Work',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),

              if (_userRole == 'ADMIN')
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminPage()),
                    );
                  },
                  leading: Image.asset(
                    'assets/admin.png',
                    width: 34,
                    height: 34,
                  ),
                  title: const Text(
                    'Admin',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),

              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BookmarkPage()),
                  );
                },
                leading: Image.asset(
                  'assets/bookmarkplus.png',
                  width: 34,
                  height: 34,
                ),
                title: const Text(
                  'Saved',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),

              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutPage()),
                  );
                },
                leading: Image.asset(
                  'assets/about.png',
                  width: 34,
                  height: 34,
                ),
                title: const Text(
                  'About',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),

              ListTile(
                onTap: _showLogoutDialog,
                leading: Image.asset(
                  'assets/logout.png',
                  width: 34,
                  height: 34,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),

              // Developer Credit
               const Padding(
                padding: EdgeInsets.symmetric(vertical: 70.0),
                child: Text(
                  'Developed by ANIL A S',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
