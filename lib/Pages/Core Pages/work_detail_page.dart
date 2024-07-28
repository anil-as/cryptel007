import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkDetailPage extends StatelessWidget {
  final String workOrderNumber;

  const WorkDetailPage({super.key, required this.workOrderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Work Details - $workOrderNumber',
          style: GoogleFonts.raleway(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('work')
            .doc(workOrderNumber)
            .get(),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(
                  title: 'Work Title',
                  content: workData['WorkTitle'] ?? 'N/A',
                  icon: Icons.title,
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  title: 'Work Description',
                  content: workData['WorkDescription'] ?? 'N/A',
                  icon: Icons.description,
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  title: 'Work Order Number',
                  content: workOrderNumber,
                  icon: Icons.confirmation_number,
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  title: 'Creation Date',
                  content: workData['creationDate'] != null
                      ? DateFormat('yyyy-MM-dd – kk:mm').format(
                          (workData['creationDate'] as Timestamp).toDate(),
                        )
                      : 'N/A',
                  icon: Icons.date_range,
                ),
                const SizedBox(height: 20),
                _buildContactInfo(
                  contacts: workData['contacts'] as List<dynamic>? ?? [],
                ),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text('Back', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title, required String content, required IconData icon}) {
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
          Icon(icon, color: Colors.blue, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.raleway(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: GoogleFonts.raleway(fontSize: 16, color: Colors.black87),
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
          content: 'Name: ${contactMap['name']}\nNumber: ${contactMap['number']}',
          icon: Icons.contact_phone,
        );
      }).toList(),
    );
  }
}
