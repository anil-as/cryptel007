import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Tools/colors.dart';

class AddWorkPage extends StatefulWidget {
  final String userEmail;

  const AddWorkPage({required this.userEmail, super.key});

  @override
  _AddWorkPageState createState() => _AddWorkPageState();
}

class _AddWorkPageState extends State<AddWorkPage> {
  final TextEditingController _clientInfoController = TextEditingController();
  final TextEditingController _materialsInfoController = TextEditingController();
  final TextEditingController _drawingsController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final TextEditingController _focalPointsController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _clientInfoController.dispose();
    _materialsInfoController.dispose();
    _drawingsController.dispose();
    _contactInfoController.dispose();
    _focalPointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Work',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.mediumGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _clientInfoController,
                  label: 'Client Info',
                  maxLength: 100,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _materialsInfoController,
                  label: 'Materials Info',
                  maxLength: 100,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _drawingsController,
                  label: 'Drawings',
                  maxLength: 100,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _contactInfoController,
                  label: 'Contact Info',
                  maxLength: 100,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _focalPointsController,
                  label: 'Focal Points',
                  maxLength: 100,
                ),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitWork,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.logoblue,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required int maxLength,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: null,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter $label',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  void _submitWork() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      firestore.collection('work').doc(widget.userEmail).set({
        'clientInfo': _clientInfoController.text,
        'materialsInfo': _materialsInfoController.text,
        'drawings': _drawingsController.text,
        'contactInfo': _contactInfoController.text,
        'focalPoints': _focalPointsController.text,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Work added successfully')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add work: $error')),
        );
      });
    }
  }
}
