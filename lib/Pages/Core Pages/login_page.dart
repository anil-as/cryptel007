// ignore_for_file: use_build_context_synchronously

import 'package:cryptel007/Pages/Navigation%20Pages/home_page.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:cryptel007/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      bool result = await AuthMethods()
          .signInWithGoogle(); // Call signInWithGoogle from AuthMethods

      if (result) {
        // Navigate to home page on successful sign-in
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // Handle sign-in failure if needed
      }
    } catch (e) {
      print('Failed to sign in with Google: $e');
      // Handle error, show message or retry option
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.logoblue,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _animation,
                child:
                    Image.asset('assets/apklogo.png', height: 200, width: 200),
              ),
              FadeTransition(
                opacity: _animation,
                child: Text(
                  'CRYPTEL',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.roboto().fontFamily,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _animation,
                child: Text(
                  'CRYO PRECISION TECHNOLOGIES PVT LTD',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.robotoFlex().fontFamily,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    ) // Show loading indicator
                  : GestureDetector(
                      onTap: () async {
                        await  signInWithGoogle();
                      },
                      child: Container(
                        width: screenWidth * 0.9,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child:
                                  Image.asset('assets/google.png', height: 24),
                            ),
                            const Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'Raleway',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
