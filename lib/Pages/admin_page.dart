import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _currentUser != null
                ? Text('Signed in as: ${_currentUser!.displayName}')
                : const Text('Not signed in'),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Sign in with Google'),
              onPressed: _handleSignIn,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      setState(() {});
    } catch (error) {
      print('Error signing in: $error');
    }
  }
}
