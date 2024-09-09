import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Pages/Core%20Pages/login_page.dart';
import 'package:cryptel007/Pages/Navigation%20Pages/home_page.dart';
import 'package:cryptel007/Pages/Navigation%20Pages/splash_screen.dart';
import 'package:cryptel007/Pages/Sub%20Pages/access_controlpage.dart';
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
            // User is signed in, check access status
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.email)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("Error retrieving user data"));
                }

                // Retrieve the access status from Firestore
                String accessStatus = snapshot.data!['access'];

                // Navigate based on access status
                if (accessStatus == 'Accepted') {
                  return const HomePage();
                } else {
                  return AccessControlPages(accessStatus: accessStatus);
                }
              },
            );
          } else {
            // User is not signed in
            return const LoginPage();
          }
        },
      ),
    );
  }
}
