import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:cryptel007/Tools/edit_detailsdialog_box.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkHeader extends StatelessWidget {
  final Map<String, dynamic> data;

  final String? workTitle;
  final String? workPhoto;
  final Timestamp? cdate;
  final String? customerName;
  final double screenWidth;
  final double textScaleFactor;
  final String workOrderNumber;

  const WorkHeader({
    super.key,
    this.workTitle,
    this.workPhoto,
    this.cdate,
    this.customerName,
    required this.workOrderNumber,
    required this.data,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
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
                              DateFormat('MMMM dd, yyyy - hh:mm a')
                                  .format(cdate!.toDate()),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          if (customerName != null)
                            Container(
                              margin: const EdgeInsets.only(top: 8.0),
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02,
                                  vertical: 4.0),
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
        ),
        Positioned(
          bottom: screenWidth * 0.04,
          right: screenWidth * 0.04,
          child: GestureDetector(
              onTap: () => _showEditDialog(context),
              child: Image.asset(
                'assets/edit.png',
                width: 30,
                height: 30,
                color: Colors.white,
              )),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDetailsDialog(
          data: data,
          workOrderNumber: workOrderNumber,
        );
      },
    );
  }
}
