import 'package:cryptel007/Pages/Core%20Pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AccessControlPages extends StatefulWidget {
  final String accessStatus;

  const AccessControlPages({super.key, required this.accessStatus});

  @override
  State<AccessControlPages> createState() => _AccessControlPagesState();
}

class _AccessControlPagesState extends State<AccessControlPages> {
  final _googleSignIn = GoogleSignIn();

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  void _showContactSupportMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.blueAccent,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                "Please contact the manager for approval.",
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the bottom sheet
                },
                child: const Text("OK"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: widget.accessStatus == 'Denied'
            ? _buildAccessDeniedPage()
            : _buildRequestAccessPage(),
      ),
    );
  }

  Widget _buildAccessDeniedPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.block,
            color: Colors.redAccent,
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            "Access Denied",
            style: GoogleFonts.robotoMono(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "Sorry, the admin has blocked your access.",
            style: GoogleFonts.robotoFlex(
              textStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            label: const Text("Sign Out"),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestAccessPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.pending,
            color: Colors.blueAccent,
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            "Request Pending",
            style: GoogleFonts.robotoMono(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "Your access request is pending admin approval.",
            style: GoogleFonts.robotoFlex(
              textStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showContactSupportMessage,
            icon: const Icon(Icons.contact_support),
            label: const Text("Contact Support"),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
           ElevatedButton.icon(
            onPressed: logout,
            icon: const Icon(Icons.logout_sharp),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
