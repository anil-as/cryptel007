import 'package:cryptel007/Tools/colors.dart';
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
  // Show confirmation dialog
  bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Confirm Save',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to save the changes?',
          style: TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            onPressed: () {
              Navigator.of(context).pop(false); // User clicked 'Cancel'
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // User clicked 'Save'
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoblue, // Update to your specific color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      );
    },
  );

  if (confirmed ?? false) {
    // Proceed with saving the details if the user confirmed
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      await FirebaseFirestore.instance
          .collection('works')
          .doc(widget.workOrderNumber)
          .update({
            'WORKTITLE': _worktitle,
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
}


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Edit Details',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                icon: Icons.title,
                label: 'Work Title',
                initialValue: _worktitle,
                onSaved: (value) => _worktitle = value ?? '',
              ),
              _buildTextField(
                icon: Icons.business,
                label: 'Purchase Order No.',
                initialValue: _purchaseOrderNumber,
                onSaved: (value) => _purchaseOrderNumber = value ?? '',
              ),
              _buildTextField(
                icon: Icons.person,
                label: 'Customer Name',
                initialValue: _customerName,
                onSaved: (value) => _customerName = value ?? '',
              ),
              _buildTextField(
                icon: Icons.person_pin,
                label: 'Focal Point Name',
                initialValue: _focalPointName,
                onSaved: (value) => _focalPointName = value ?? '',
              ),
              _buildTextField(
                icon: Icons.phone,
                label: 'Focal Point Number',
                initialValue: _focalPointNumber,
                onSaved: (value) => _focalPointNumber = value ?? '',
              ),
              _buildTextField(
                icon: Icons.person,
                label: 'ACPL Focal Point Name',
                initialValue: _acplFocalPointName,
                onSaved: (value) => _acplFocalPointName = value ?? '',
              ),
              _buildTextField(
                icon: Icons.phone,
                label: 'ACPL Focal Point Number',
                initialValue: _acplFocalPointNumber,
                onSaved: (value) => _acplFocalPointNumber = value ?? '',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.red),
          ),
        ),
        ElevatedButton(
          onPressed: _updateDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            'Save',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    required String initialValue,
    required void Function(String?) onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onSaved: onSaved,
      ),
    );
  }
}
