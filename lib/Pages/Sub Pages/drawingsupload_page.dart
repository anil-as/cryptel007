import 'dart:io';
import 'dart:convert'; // For computing the hash
import 'package:crypto/crypto.dart'; // For hashing
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
  String? _previousImageHash;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      
      // Compute the hash of the new image
      final newImageHash = await _computeImageHash(file);

      // Compare with the previous image hash
      if (newImageHash == _previousImageHash) {
        _showAlertDialog('Cannot upload the same image twice.');
      } else {
        setState(() {
          _selectedImage = file;
          _previousImageHash = newImageHash;
        });
      }
    }
  }

  // Function to compute the hash of the image
  Future<String> _computeImageHash(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return sha256.convert(bytes).toString(); // Hashing with SHA-256
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

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Drawing'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Drawing Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _drawingIDController,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Drawing ID',
                labelStyle: const TextStyle(color: Colors.black45),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black26),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black87),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _selectedImage != null
                ? GestureDetector(
                    onTap: () {
                      _pickImage();
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.file(
                          _selectedImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.black26),
                      
                      ),
                      child: const Center(
                        child: Text(
                          'No image selected\nTap to pick an image',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 30),
            _isUploading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black87,
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _uploadDrawing,
                    icon: const Icon(Icons.cloud_upload_outlined,color: Colors.white,),
                    label: const Text('Upload Drawing',style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56), // Matching width
                      textStyle: const TextStyle(fontSize: 18),
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
