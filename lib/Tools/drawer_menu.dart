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
                backgroundColor:Colors.red,
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
                        if(_userRole != 'USER')
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
                    MaterialPageRoute(builder: (context) => const AddWorkPage()),
                  );
                } else {
                  _showAccessDeniedDialog();
                }
              },
              leading:  Image.asset('assets/project.png',width: 37,height: 37,),
              title: const Text('Work'),
              trailing: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            //  ListTile(
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) =>  const BookmarkPage()),
            //     );
            //   },
            //   leading:  Image.asset('assets/search.png',width: 37,height: 37,),
            //   title: const Text('Search'),
            // ),
            if(_userRole == 'ADMIN')
            ListTile(
              onTap: () {
                if (_userRole == 'ADMIN') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPage()),
                  );
                } else {
                  _showAccessDeniedDialog();
                }
              },
              leading: Image.asset('assets/admin.png',width: 37,height: 37,),
              title: const Text('Admin'),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookmarkPage()),
                );
              },
              leading:  Image.asset('assets/bookmarkplus.png',width: 37,height: 37,),
              title: const Text('Saved'),
            ),
             ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  AboutPage()),
                );
              },
              leading:  Image.asset('assets/about.png',width: 37,height: 37,),
              title: const Text('About'),
            ),
            
            ListTile(
              onTap: _showLogoutDialog,
              leading:  Image.asset('assets/logout.png',width: 37,height: 37,),
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
