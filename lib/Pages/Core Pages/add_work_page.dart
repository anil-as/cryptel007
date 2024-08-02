import 'dart:io';
import 'package:cryptel007/Pages/Core%20Pages/specific_work_page.dart';
import 'package:cryptel007/Pages/Core%20Pages/work_detail_page.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:cryptel007/Tools/custom_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AddWorkPage extends StatefulWidget {
  const AddWorkPage({super.key});

  @override
  _AddWorkPageState createState() => _AddWorkPageState();
}

class _AddWorkPageState extends State<AddWorkPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false; // Loading state

  String _worktitle = '';
  String _workOrderNumber = '';
  String _purchaseordernumber = '';
  String _customername = '';
  String _focalpointName = '';
  String _focalpointNumber = '';
  String _acplfocalpointName = '';
  String _acplfocalpointNumber = '';
  String _password = '';
  final DateTime _creationDate = DateTime.now();
  XFile? _photo; // Selected image

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String? photoUrl;

    if (_photo != null) {
      photoUrl = await _uploadPhoto();
      if (photoUrl == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    final workData = {
      'WORKTITLE': _worktitle,
      'WONUMBER': _workOrderNumber,
      'PONUMBER': _purchaseordernumber,
      'CUSTOMERNAME': _customername,
      'CDATE': _creationDate,
      'FOCALPOINTNAME': _focalpointName,
      'FOCALPOINTNUMBER': _focalpointNumber,
      'ACPLFOCALPOINTNAME': _acplfocalpointName,
      'ACPLFOCALPOINTNUMBER': _acplfocalpointNumber,
      'PASSWORD': _password,
      'PHOTO': photoUrl,
    };

    try {
      await FirebaseFirestore.instance
          .collection('works')
          .doc(_workOrderNumber)
          .set(workData);

      _showSnackBar('Data successfully saved');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkDetailPage(workOrderNumber: _workOrderNumber),
        ),
      );
    } catch (e) {
      _showSnackBar('Error saving data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _uploadPhoto() async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('workphotos/$_workOrderNumber.jpg');

      final uploadTask = storageRef.putFile(File(_photo!.path));
      final snapshot = await uploadTask.whenComplete(() => {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      _showSnackBar('Error uploading photo: $e');
      return null;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _photo = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Enter Work Details'),
  backgroundColor: Colors.grey[200],
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pushReplacementNamed(context, '/home'); // Replace '/home' with your route name for HomePage
    },
  ),
),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoField(),
                  _buildTextField('Work Title', (value) => _worktitle = value),
                  _buildTextField('Work Order Number', (value) => _workOrderNumber = value),
                  _buildTextField('Purchase Order No.', (value) => _purchaseordernumber = value),
                  _buildTextField('Customer Name', (value) => _customername = value),
                  _buildFocalPointFields(),
                  _buildAcplFocalPointFields(),
                  _buildPasswordField(),
                  const SizedBox(height: 20),
                  Center(
                    child: CustomButton(
                      borderRadius: 22,
                      h: 60,
                      text: 'Create',
                      fsize: 20,
                      onPressed: _saveData,
                      buttonColor: AppColors.logoblue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Creation Date: ${DateFormat('yyyy-MM-dd – kk:mm').format(_creationDate)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: _pickImage,
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey),
          ),
          alignment: Alignment.center,
          child: _photo == null
              ? Center(
                  child: Icon(
                    Icons.add_a_photo,
                    color: Colors.grey[600],
                    size: 50,
                  ),
                )
              : Image.file(
                  File(_photo!.path),
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    ValueChanged<String> onChanged, {
    int maxLines = 1,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text, // Default to text input
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          maxLines: maxLines,
          obscureText: obscureText,
          onChanged: onChanged,
          keyboardType: keyboardType, // Apply keyboard type
          validator: (value) => value!.isEmpty ? 'Please enter the $label' : null,
        ),
      ),
    );
  }

  Widget _buildFocalPointFields() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildTextField(
              'Focal Point Name',
              (value) => _focalpointName = value,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTextField(
              'Focal Point Number',
              (value) => _focalpointNumber = value,
              keyboardType: TextInputType.number, // Set keyboard type to number
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcplFocalPointFields() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildTextField(
              'ACPL Focal Point Name',
              (value) => _acplfocalpointName = value,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTextField(
              'ACPL Focal Point Number',
              (value) => _acplfocalpointNumber = value,
              keyboardType: TextInputType.number, // Set keyboard type to number
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          obscureText: _obscurePassword,
          onChanged: (value) => _password = value,
          validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
        ),
      ),
    );
  }
}
