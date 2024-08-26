import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class DrawingUploadPage extends StatefulWidget {
  final String workOrderNumber;

  const DrawingUploadPage({required this.workOrderNumber});

  @override
  _DrawingUploadPageState createState() => _DrawingUploadPageState();
}

class _DrawingUploadPageState extends State<DrawingUploadPage> {
  final TextEditingController _drawingIDController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadDrawing() async {
    final drawingID = _drawingIDController.text;

    if (drawingID.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Drawing ID and select an image')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('work_drawings')
          .child(widget.workOrderNumber)
          .child('$drawingID.jpg');

      await storageRef.putFile(_selectedImage!);
      final downloadURL = await storageRef.getDownloadURL();

      // Store the download URL in Firestore
      await FirebaseFirestore.instance
          .collection('works')
          .doc(widget.workOrderNumber)
          .collection('Drawings')
          .doc(drawingID)
          .set({'url': downloadURL});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drawing uploaded successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload drawing: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Drawing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _drawingIDController,
              decoration: const InputDecoration(labelText: 'Drawing ID'),
            ),
            const SizedBox(height: 10),
            _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  )
                : const Text('No image selected'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadDrawing,
                    child: const Text('Upload'),
                  ),
          ],
        ),
      ),
    );
  }
}
