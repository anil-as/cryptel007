import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> data;
  final String workOrderNumber;

  const EditDetailsDialog({
    super.key,
    required this.data,
    required this.workOrderNumber,
  });

  @override
  _EditDetailsDialogState createState() => _EditDetailsDialogState();
}

class _EditDetailsDialogState extends State<EditDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _worktitle;
  late String _purchaseOrderNumber;
  late String _customerName;
  late String _focalPointName;
  late String _focalPointNumber;
  late String _acplFocalPointName;
  late String _acplFocalPointNumber;

  @override
  void initState() {
    super.initState();
    _worktitle = widget.data['WORKTITLE'] ?? '';
    _purchaseOrderNumber = widget.data['PONUMBER'] ?? '';
    _customerName = widget.data['CUSTOMERNAME'] ?? '';
    _focalPointName = widget.data['FOCALPOINTNAME'] ?? '';
    _focalPointNumber = widget.data['FOCALPOINTNUMBER'] ?? '';
    _acplFocalPointName = widget.data['ACPLFOCALPOINTNAME'] ?? '';
    _acplFocalPointNumber = widget.data['ACPLFOCALPOINTNUMBER'] ?? '';
  }

  Future<void> _updateDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      await FirebaseFirestore.instance
          .collection('works')
          .doc(widget.workOrderNumber)
          .update({
            'WORKTITLE':_worktitle,
        'PONUMBER': _purchaseOrderNumber,
        'CUSTOMERNAME': _customerName,
        'FOCALPOINTNAME': _focalPointName,
        'FOCALPOINTNUMBER': _focalPointNumber,
        'ACPLFOCALPOINTNAME': _acplFocalPointName,
        'ACPLFOCALPOINTNUMBER': _acplFocalPointNumber,
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Details'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               TextFormField(
                initialValue: _worktitle,
                decoration: const InputDecoration(labelText: 'Work Title'),
                onSaved: (value) => _worktitle = value ?? '',
              ),
              TextFormField(
                initialValue: _purchaseOrderNumber,
                decoration: const InputDecoration(labelText: 'Purchase Order No.'),
                onSaved: (value) => _purchaseOrderNumber = value ?? '',
              ),
              TextFormField(
                initialValue: _customerName,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                onSaved: (value) => _customerName = value ?? '',
              ),
              TextFormField(
                initialValue: _focalPointName,
                decoration: const InputDecoration(labelText: 'Focal Point Name'),
                onSaved: (value) => _focalPointName = value ?? '',
              ),
              TextFormField(
                initialValue: _focalPointNumber,
                decoration: const InputDecoration(labelText: 'Focal Point Number'),
                onSaved: (value) => _focalPointNumber = value ?? '',
              ),
              TextFormField(
                initialValue: _acplFocalPointName,
                decoration: const InputDecoration(labelText: 'ACPL Focal Point Name'),
                onSaved: (value) => _acplFocalPointName = value ?? '',
              ),
              TextFormField(
                initialValue: _acplFocalPointNumber,
                decoration: const InputDecoration(labelText: 'ACPL Focal Point Number'),
                onSaved: (value) => _acplFocalPointNumber = value ?? '',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateDetails,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
