import 'package:flutter/material.dart';

Future<void> showSaveConfirmationDialog(
  BuildContext context,
  Future<void> Function() onConfirm,
) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Save'),
        content: const Text('Are you sure you want to save these changes?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog before async operation
              await onConfirm(); // Trigger the save function
              print('Save function triggered');
            },
          ),
        ],
      );
    },
  );
}
