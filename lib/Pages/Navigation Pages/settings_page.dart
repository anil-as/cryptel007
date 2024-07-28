import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Pages/Core%20Pages/add_work_page.dart';
import 'package:cryptel007/Pages/Core%20Pages/login_page.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Sub Pages/admin_page.dart'; // Import your admin page here

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  String? _userRole;
  StreamSubscription<GoogleSignInAccount?>? _userStream;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userStream = _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      if (mounted) {
        setState(() {
          _currentUser = account;
        });
      }
      if (account != null) {
        _fetchUserRole(account.email);
      }
    });

    _googleSignIn.signInSilently().then((GoogleSignInAccount? account) {
      if (account != null) {
        _fetchUserRole(account.email);
      }
    });
  }

  @override
  void dispose() {
    _userStream?.cancel();
    super.dispose();
  }

  Future<void> _fetchUserRole(String? email) async {
    if (email == null) return;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();
    if (mounted) {
      setState(() {
        _userRole = userDoc['role'];
        _isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser?.email ?? '',
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userRole ?? '',
                            style: const TextStyle(fontSize: 16, color: AppColors.logoblue),
                          ),
                        ],
                      ),
                    ),
                  ),
                 Expanded(
  child: GridView.count(
    crossAxisCount: 2, // Number of cards per row
    childAspectRatio: 1.5, // Aspect ratio of each card
    children: [
      _buildCardTile(
        icon: Icons.add,
        title: 'Add Work',
        color: AppColors.logoblue,
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
      ),
      _buildCardTile(
        icon: Icons.notifications,
        title: 'Notifications',
        color:AppColors.logoblue,
        onTap: () {
          // Handle Notifications tap
        },
      ),
      _buildCardTile(
        icon: Icons.security,
        title: 'Control Hub',
        color:AppColors.logoblue,
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
      ),
      _buildCardTile(
        icon: Icons.help,
        title: 'Help & Support',
        color:AppColors.logoblue,
        onTap: () {
          // Handle Help & Support tap
        },
      ),
      _buildCardTile(
        icon: Icons.info,
        title: 'About',
        color:AppColors.logoblue,
        onTap: () {
          // Handle About tap
        },
      ),
      _buildCardTile(
        icon: Icons.logout_rounded,
        title: 'Logout',
        color:AppColors.logoblue,
        onTap: _showLogoutDialog,
      ),
    ],
  ),
)
                ],
              ),
            ),
    );
  }
Widget _buildCardTile({
  required IconData icon,
  required String title,
  required Color color,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 5,
    color: color, // Use the provided color for the card
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white), // Use white color for the icon
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)), // Use white color for the text
          ],
        ),
      ),
    ),
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
                backgroundColor: AppColors.logoblue,
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
}
