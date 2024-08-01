import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import this for making phone calls

class DetailsContainer extends StatelessWidget {
  final Map<String, dynamic> data;
  final double screenWidth;
  final double textScaleFactor;

  const DetailsContainer({
    super.key,
    required this.data,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Work Order Number', data['WONUMBER']),
          const Divider(),
          _buildDetailRow('Purchase Order No.', data['PONUMBER']),
          const Divider(),
          _buildDetailRow('Customer Name', data['CUSTOMERNAME']),
          const Divider(),
          _buildContactDetail('Focal Point', data['FOCALPOINTNAME'], data['FOCALPOINTNUMBER']),
          const Divider(),
          _buildContactDetail('ACPL Focal Point', data['ACPLFOCALPOINTNAME'], data['ACPLFOCALPOINTNUMBER']),
          // Creation Date and Edited Date removed
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 16 * textScaleFactor, // Adjusted font size
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontSize: 18 * textScaleFactor, // Adjusted font size
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetail(String label, String? name, String? number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 16 * textScaleFactor, // Adjusted font size
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name != null && name.isNotEmpty) 
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18 * textScaleFactor, // Adjusted font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (number != null && number.isNotEmpty) 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 4),
                      Text(
                        number,
                        style: TextStyle(
                          fontSize: 18 * textScaleFactor, // Adjusted font size
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.call,
                          color: Colors.green,
                          size: 28 * textScaleFactor, // Increased size
                        ),
                        onPressed: () => _makePhoneCall(number),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String? number) async {
    if (number != null && number.isNotEmpty) {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: number,
      );
      await launchUrl(launchUri);
    }
  }
}
