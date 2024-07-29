import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:cryptel007/Tools/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

class WorkDetailPage extends StatelessWidget {
  final String workOrderNumber;

  const WorkDetailPage({super.key, required this.workOrderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            icon: Image.asset('assets/arrow.png'),
            onPressed: () {
              Navigator.pop(context);
            },
            iconSize: 7,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_suggest_sharp, // Settings icon
              color: Colors.black,
              size: 34, // Adjust the size as needed
            ),
            onPressed: () {
              // Add your onPressed logic here
            },
          )
        ],
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('work')
            .doc(workOrderNumber)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.blue),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'No data found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final workData = snapshot.data!.data() as Map<String, dynamic>?;

          if (workData == null) {
            return const Center(
              child: Text(
                'No data found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final double percentage = workData['percentage'] != null
              ? workData['percentage'] / 100.0
              : 0.5;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleCard(
                  Subtitle: workData['creationDate'] != null
                      ? DateFormat('yyyy-MM-dd – hh:mm').format(
                          (workData['creationDate'] as Timestamp).toDate(),
                        )
                      : 'N/A',
                  title: 'Work Title',
                  content: workData['WorkTitle'] ?? 'N/A',
                  icon: Icons.title,
                  percentage: percentage,
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  content: (workData['WorkDescription'] ?? 'N/A').toUpperCase(),
                  title: 'Description',
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  title: 'Work Order No',
                  content: workOrderNumber,
                ),
                const SizedBox(height: 20),
                _buildContactInfo(
                  contacts: workData['contacts'] as List<dynamic>? ?? [],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:CustomButton(text: 'Go to Jobcard', onPressed: (){})
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child:CustomButton(text: 'Go to Drawings', onPressed: (){})
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleCard({
    required String title,
    required String content,
    required String Subtitle,
    required IconData icon,
    required double percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/work.png',
            width: 70,
            height: 70,
          ),
          const SizedBox(width: 37),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Subtitle,
                  style: GoogleFonts.strait(fontSize: 17, color: Colors.black),
                ),
                const SizedBox(height: 3),
                Text(
                  content.toUpperCase(),
                  style: GoogleFonts.strait(fontSize: 27, color: Colors.black),
                ),
              ],
            ),
          ),
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 8.0,
            percent: percentage,
            center: Text(
              '${(percentage * 100).toStringAsFixed(1)}%',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            progressColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    String? title,
    required String content,
    IconData? icon,
    bool showTitle = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, color: AppColors.logoblue, size: 30),
          if (icon != null) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTitle && title != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.logoblue,
                      ),
                    ),
                  ),
                Text(
                  content,
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo({required List<dynamic> contacts}) {
    if (contacts.isEmpty) {
      return _buildInfoCard(
        title: 'Contact Info',
        content: 'No contacts available',
        icon: Icons.contact_phone,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contacts.map((contact) {
        final contactMap = contact as Map<String, dynamic>;
        return _buildInfoCard(
          title: 'Contact Info',
          content:
              'Name: ${contactMap['name']}\nNumber: ${contactMap['number']}',
          icon: Icons.contact_phone,
        );
      }).toList(),
    );
  }
}
