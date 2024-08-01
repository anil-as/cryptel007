import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkHeader extends StatelessWidget {
  final String? workTitle;
  final String? workPhoto;
  final Timestamp? cdate;
  final String? customerName;
  final double screenWidth;
  final double textScaleFactor;

  const WorkHeader({
    super.key,
    this.workTitle,
    this.workPhoto,
    this.cdate,
    this.customerName,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: AppColors.logoblue,
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
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/whitelogo.png',
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workTitle?.toUpperCase() ?? 'NO TITLE AVAILABLE',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (cdate != null)
                        Text(
                          DateFormat('MMMM dd, yyyy - hh:mm a').format(cdate!.toDate()),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      if (customerName != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8.0),
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            customerName!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14 * textScaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                ClipOval(
                  child: workPhoto != null
                      ? Image.network(
                          workPhoto!,
                          width: 70.0,
                          height: 70.0,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.photo,
                          size: 100.0,
                          color: Colors.grey[600],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
