import 'package:cryptel007/Pages/Core%20Pages/login_page.dart';
import 'package:cryptel007/Tools/bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const BottomNavPage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
