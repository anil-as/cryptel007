import 'dart:io';
import 'package:cryptel007/Pages/Core%20Pages/work_detail_page.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:cryptel007/Tools/custom_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

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
  String _CPTfocalpointName = '';
  String _CPTfocalpointNumber = '';
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
      'CUSTOMERNAME_LOWER': _customername.toLowerCase(),
      'CDATE': _creationDate,
      'FOCALPOINTNAME': _focalpointName,
      'FOCALPOINTNUMBER': _focalpointNumber,
      'CPTFOCALPOINTNAME': _CPTfocalpointName,
      'CPTFOCALPOINTNUMBER': _CPTfocalpointNumber,
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
          builder: (context) =>
              WorkDetailPage(workOrderNumber: _workOrderNumber),
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
      final File imageFile = File(_photo!.path);
      if (!await imageFile.exists()) {
        _showSnackBar('Selected image file does not exist.');
        return null;
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('workphotos/$_workOrderNumber.jpg');

      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      _showSnackBar('Error uploading photo: $e');
      return null;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12.0), // Set the border radius here
          ),
          title: const Text(
            'Select Image Source',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final XFile? pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context, pickedFile);
              },
              child: const Text('Take Photo'),
            ),
            TextButton(
              onPressed: () async {
                final XFile? pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, pickedFile);
              },
              child: const Text('Choose from Gallery'),
            ),
          ],
        );
      },
    );

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
            Navigator.pushReplacementNamed(context,
                '/home'); // Replace '/home' with your route name for HomePage
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoField(),
                  const SizedBox(height: 7),
                  _buildTextField('Work Title', (value) => _worktitle = value),
                  const SizedBox(height: 7),
                  _buildTextField(
                      'Work Order Number', (value) => _workOrderNumber = value),
                  const SizedBox(height: 7),
                  _buildTextField('Purchase Order No.',
                      (value) => _purchaseordernumber = value),
                  const SizedBox(height: 7),
                  _buildTextField(
                      'Customer Name', (value) => _customername = value),
                  const SizedBox(height: 7),
                  _buildFocalPointFields(),
                  const SizedBox(height: 7),
                  _buildCPTFocalPointFields(),
                  const SizedBox(height: 7),
                  _buildPasswordField(),
                  const SizedBox(height: 7),
                  Center(
                    child: CustomButton(
                      borderRadius: 12,
                      h: 50,
                      text: 'Create',
                      fsize: 14,
                      onPressed: _saveData,
                      buttonColor: AppColors.logoblue,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Center(
                    child: Text(
                      'Creation Date: ${DateFormat('yyyy-MM-dd – kk:mm').format(_creationDate)}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
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
    return InkWell(
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
    );
  }

 Widget _buildTextField(
  String label,
  ValueChanged<String> onChanged, {
  int maxLines = 1,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  bool allowSpecialChars = true,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(color: Colors.grey),
    ),
    child: TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      maxLines: maxLines,
      obscureText: obscureText,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: allowSpecialChars
          ? [] // Allow all characters
          : [FilteringTextInputFormatter.deny(RegExp(r'[/-]'))], // Allow no special chars
      validator: (value) => value!.isEmpty ? 'Please enter the $label' : null,
    ),
  );
}

  Widget _buildFocalPointFields() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            'Focal Point Name',
            (value) => _focalpointName = value,
            allowSpecialChars: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTextField(
            'Focal Point No.',
            (value) => _focalpointNumber = value,
            keyboardType: TextInputType.number, // Set keyboard type to number
            allowSpecialChars: false, // No special chars allowed
          ),
        ),
      ],
    );
  }

  Widget _buildCPTFocalPointFields() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            'CPT Focal Point Name',
            (value) => _CPTfocalpointName = value,
            allowSpecialChars: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTextField(
            'CPT Focal Point No.',
            (value) => _CPTfocalpointNumber = value,
            keyboardType: TextInputType.number, // Set keyboard type to number
            allowSpecialChars: false, // No special chars allowed
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey),
      ),
      child: TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        obscureText: _obscurePassword,
        onChanged: (value) => _password = value,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9/-]')),
        ],
        validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
      ),
    );
  }
}
