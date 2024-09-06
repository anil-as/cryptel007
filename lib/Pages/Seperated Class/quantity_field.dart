import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuantityField extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const QuantityField({
    super.key,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Quantity:',
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 16), // Space between the label and quantity
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: onDecrease,
        ),
        Text(
          quantity.toString(),
          style: GoogleFonts.lato(fontSize: 18,fontWeight:  FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onIncrease,
        ),
      ],
    );
  }
}
