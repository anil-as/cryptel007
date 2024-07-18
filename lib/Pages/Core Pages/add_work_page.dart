import 'package:cryptel007/Tools/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class AddWorkPage extends StatefulWidget {
  const AddWorkPage({super.key});

  @override
  _AddWorkPageState createState() => _AddWorkPageState();
}

class _AddWorkPageState extends State<AddWorkPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedTenderType = 'Type A';
  bool _useSpecialTools = false;
  File? _workImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _workImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Work Details'),
        backgroundColor: Colors.grey[200],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tender Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.logoblue,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tender Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the tender title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tender Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the tender description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Tender Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: const Text('Type A'),
                leading: Radio<String>(
                  value: 'Type A',
                  groupValue: _selectedTenderType,
                  onChanged: (value) {
                    setState(() {
                      _selectedTenderType = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Type B'),
                leading: Radio<String>(
                  value: 'Type B',
                  groupValue: _selectedTenderType,
                  onChanged: (value) {
                    setState(() {
                      _selectedTenderType = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Use Special Tools',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                title: const Text('Special Tools Required'),
                value: _useSpecialTools,
                onChanged: (value) {
                  setState(() {
                    _useSpecialTools = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Work Image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: _workImage == null
                      ? const Icon(Icons.add_a_photo, size: 50)
                      : Image.file(_workImage!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.logoblue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process the form data
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
