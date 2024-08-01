import 'dart:io';
import 'package:cryptel007/Pages/Core%20Pages/work_detail_page.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:cryptel007/Tools/custom_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isLoading = false; // Added loading state

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
  XFile? _photo; // To store selected image

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Set loading to true
      });

      String? photoUrl;

      // If a photo was selected, upload it to Firebase Storage
      if (_photo != null) {
        try {
          // Create a reference to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('workphotos/$_workOrderNumber.jpg');

          // Upload the photo
          final uploadTask = storageRef.putFile(File(_photo!.path));
          final snapshot = await uploadTask.whenComplete(() => {});
          photoUrl = await snapshot.ref.getDownloadURL();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading photo: $e')),
          );
          setState(() {
            _isLoading = false; // Set loading to false on error
          });
          return; // Exit if photo upload fails
        }
      }

      // Prepare the data to save in Firestore
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
        'EDITEDDATE': _creationDate, // Set initial edited date to creation date
        'PHOTO': photoUrl ?? null, // Handle null photo URL
      };

      try {
        // Save data to Firestore
        await FirebaseFirestore.instance
            .collection('works')
            .doc(_workOrderNumber)
            .set(workData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data successfully saved')),
        );

        // Navigate to WorkDetailPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WorkDetailPage(workOrderNumber: _workOrderNumber),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Set loading to false after processing
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

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
        elevation: 0, // Remove shadow for a flatter look
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
                  _buildPhotoField(), // Add photo field at the top
                  _buildTextField(
                    label: 'Work Title',
                    onChanged: (value) => setState(() => _worktitle = value),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter the Work title' : null,
                  ),
                  _buildTextField(
                    label: 'Work Order Number',
                    onChanged: (value) => setState(() => _workOrderNumber = value),
                    validator: (value) => value!.isEmpty
                        ? 'Please enter the work order number'
                        : null,
                  ),
                  _buildTextField(
                    label: 'Purchase Order No.',
                    maxLines: 1,
                    onChanged: (value) =>
                        setState(() => _purchaseordernumber = value),
                    validator: (value) => value!.isEmpty
                        ? 'Please enter the purchase order number'
                        : null,
                  ),
                  _buildTextField(
                    label: 'Customer Name',
                    maxLines: 1,
                    onChanged: (value) => setState(() => _customername = value),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter the customer name' : null,
                  ),
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
          if (_isLoading) // Display loading indicator if _isLoading is true
            Center(
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
          height: 200, // Adjust the height to fit your design
          decoration: BoxDecoration(
            color: Colors.grey[300],
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

  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    bool obscureText = false,
    required ValueChanged<String> onChanged,
    required FormFieldValidator<String> validator,
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
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontSize: 14, // Set font size to 14
              color: Colors.grey[600],
            ),
            border: InputBorder.none, // No border
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          maxLines: maxLines,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Focal Point Name',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                onChanged: (value) => setState(() => _focalpointName = value),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the focal point name' : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Focal Point Number',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                onChanged: (value) => setState(() => _focalpointNumber = value),
                validator: (value) => value!.isEmpty
                    ? 'Please enter the focal point number'
                    : null,
              ),
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'ACPL Focal Point Name',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                onChanged: (value) => setState(() => _acplfocalpointName = value),
                validator: (value) => value!.isEmpty
                    ? 'Please enter the ACPL focal point name'
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'ACPL Focal Point Number',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                onChanged: (value) => setState(() => _acplfocalpointNumber = value),
                validator: (value) => value!.isEmpty
                    ? 'Please enter the ACPL focal point number'
                    : null,
              ),
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
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
          ),
          onChanged: (value) => setState(() => _password = value),
          validator: (value) =>
              value!.isEmpty ? 'Please enter the password' : null,
        ),
      ),
    );
  }
}
