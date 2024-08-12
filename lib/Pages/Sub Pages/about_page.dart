import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cryptel007/Tools/colors.dart';

class AboutPage extends StatelessWidget {
  AboutPage({super.key});

  // Define the URL you want to open in the in-app web view
  final Uri websiteUri = Uri.parse('https://www.cryptel.co.in');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
        backgroundColor: AppColors.logoblue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.logoblue, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About CRYPTEL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'CRYPTEL is an AS 9100:D certified Aerospace manufacturing company founded in 2009. Our factory is located in SIDCO Industrial estate, Umayanalloor near Kollam Trivandrum highway. CRYPTEL was started with CNC machining facility with 2 CNC machines and other supporting machines. Now the company has 10 CNC machines, CNC CMM, Jigboring machine and various types of conventional machines. Within a period of 10 years CRYPTEL could progressively improve its quality and production. We are delivering quality products to our valued customers within scheduled time. Our major customers are VSSC, LPSC, IISU, SIDCO, GTRE, URSC Bangalore, DRDL Hyderabad and BrahMos Aerospace Trivandrum. Cryo Precision Technologies.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Our Mission',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'CRYPTEL has been created to address the high demand, in the Aerospace Industry, for reliable precision manufacturing services.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(FontAwesomeIcons.mapMarkerAlt, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cryo Precision Technologies Pvt. Ltd., SIDCO Industrial estate, Palathara road, Umayanalloor, Kollam-691589',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchURL('tel:+919496471846'),
                  child: const Row(
                    children: [
                      Icon(FontAwesomeIcons.phone, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Phone: +91 94964 71846',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchURL('mailto:info@cryptel.co.in'),
                  child: const Row(
                    children: [
                      Icon(FontAwesomeIcons.envelope, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Email: info@cryptel.co.in',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchURL(websiteUri.toString()),
                  child: const Row(
                    children: [
                      Icon(FontAwesomeIcons.globe, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Website: cryptel.co.in',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Business Hours',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Opening Days: Monday – Saturday: 9am to 8pm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Copyright ©2024 All rights reserved | Developed by XPECTO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 70),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _launchURL('https://twitter.com/yourprofile'),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(FontAwesomeIcons.twitter, color: Colors.blue.shade600),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _launchURL('https://facebook.com/yourprofile'),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(FontAwesomeIcons.facebookF, color: Colors.blue.shade900),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _launchURL('https://linkedin.com/in/yourprofile'),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(FontAwesomeIcons.linkedinIn, color: Colors.blue.shade800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle the error or show a message
      print('Could not launch $url');
    }
  }
}
