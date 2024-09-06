import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PercentageSelector extends StatelessWidget {
  final double completion;
  final ValueChanged<double> onChanged;

  const PercentageSelector({
    Key? key,
    required this.completion,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Completion: ${completion.toStringAsFixed(0)}%',
          style: GoogleFonts.lato( fontSize: 18,
            fontWeight: FontWeight.bold,),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showPercentageChanger(context),
          child: const Icon(Icons.edit, color: Colors.black),
        ),
      ],
    );
  }

  Future<void> _showPercentageChanger(BuildContext context) async {
    double selectedPercentage = completion;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              contentPadding: const EdgeInsets.all(20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular Percentage Display with Draggable Circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onPanUpdate: (details) {
                          final RenderBox box = context.findRenderObject() as RenderBox;
                          final offset = box.globalToLocal(details.globalPosition);
                          final center = Offset(box.size.width / 2, box.size.height / 2);
                          final angle = (atan2(offset.dy - center.dy, offset.dx - center.dx) + pi / 2) % (2 * pi);

                          setState(() {
                            selectedPercentage = (angle / (2 * pi)) * 100;
                            if (selectedPercentage > 100) selectedPercentage = 100;
                            if (selectedPercentage < 0) selectedPercentage = 0;
                          });
                        },
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: selectedPercentage / 100,
                            strokeWidth: 10,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getColorFromPercentage(selectedPercentage),
                            ),
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                      ),
                      // Center Circle Button
                      InkWell(
                        onTap: () {
                          Navigator.pop(context, selectedPercentage);
                        },
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            '${selectedPercentage.toStringAsFixed(0)}%',
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((value) {
      if (value != null) {
        onChanged(value);
      }
    });
  }

  // Helper function to change color based on percentage
  Color _getColorFromPercentage(double percentage) {
    if (percentage <= 33) {
      return Colors.redAccent;
    } else if (percentage <= 66) {
      return Colors.orangeAccent;
    } else {
      return Colors.greenAccent;
    }
  }
}
