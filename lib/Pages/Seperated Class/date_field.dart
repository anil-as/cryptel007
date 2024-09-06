import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateField extends StatelessWidget {
  final TextEditingController controller;
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateField({
    super.key,
    required this.controller,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Expected Date',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 15),
      ),
      readOnly: true,
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
    );
  }
}
