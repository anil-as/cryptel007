import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfUploadPage extends StatefulWidget {
  final String workOrderNumber;
  final String workId;

  const PdfUploadPage({
    super.key,
    required this.workOrderNumber,
    required this.workId,
  });

  @override
  _PdfUploadPageState createState() => _PdfUploadPageState();
}

class _PdfUploadPageState extends State<PdfUploadPage> {
  final ImagePicker _picker = ImagePicker();
  File? _pdfFile;
  String? _pdfUrl;
  bool isLoading = false;

  Future<void> _pickPdf() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null) {
      setState(() {
        _pdfFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPdf() async {
    if (_pdfFile == null) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('pdfs/${widget.workOrderNumber}/${widget.workId}.pdf');
      await storageRef.putFile(_pdfFile!);
      _pdfUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('works')
          .doc(widget.workOrderNumber)
          .collection('specificWorks')
          .doc(widget.workId)
          .set({
        'pdfUrl': _pdfUrl,
        'lastUpdated': DateTime.now(),
      }, SetOptions(merge: true));

      setState(() {});
    } catch (e) {
      // Handle errors
      print('Error uploading PDF: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload PDF'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_pdfFile != null)
              Expanded(
                child: PDFView(
                  filePath: _pdfFile!.path,
                ),
              )
            else
              const Center(child: Text('No PDF selected')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickPdf,
              child: const Text('Pick PDF'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadPdf,
              child: const Text('Upload PDF'),
            ),
            const SizedBox(height: 20),
            if (_pdfUrl != null)
              Expanded(
                child: PDFView(
                  filePath: _pdfUrl, // URL not directly supported, use file download instead
                ),
              ),
          ],
        ),
      ),
    );
  }
}
