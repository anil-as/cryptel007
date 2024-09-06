import 'package:flutter/material.dart';

Future<void> showDeleteConfirmationDialog(
  BuildContext context,
  Future<void> Function() onConfirm,
) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this work?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () async {
              await onConfirm();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
