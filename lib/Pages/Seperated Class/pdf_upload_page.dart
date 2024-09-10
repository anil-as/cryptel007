// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';


// class PdfUploadPage extends StatefulWidget {
//   final String workOrderNumber;
//   final String workId;

//   const PdfUploadPage({
//     super.key,
//     required this.workOrderNumber,
//     required this.workId,
//   });

//   @override
//   _PdfUploadPageState createState() => _PdfUploadPageState();
// }

// class _PdfUploadPageState extends State<PdfUploadPage> {
//   File? _pdfFile;
//   String? _pdfUrl;
//   bool isLoading = false;
//   bool isDownloading = false;
//   File? _downloadedPdfFile;

//   // Pick a PDF file from the file picker
//   Future<void> _pickPdf() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom, 
//       allowedExtensions: ['pdf'],
//     );
//     if (result != null) {
//       setState(() {
//         _pdfFile = File(result.files.single.path!);
//       });
//     }
//   }

//   // Upload the selected PDF file to Firebase Storage and Firestore
//   Future<void> _uploadPdf() async {
//     if (_pdfFile == null) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('pdfs/${widget.workOrderNumber}/${widget.workId}.pdf');
//       await storageRef.putFile(_pdfFile!);
//       _pdfUrl = await storageRef.getDownloadURL();

//       // Update Firestore with the PDF URL and timestamp
//       await FirebaseFirestore.instance
//           .collection('works')
//           .doc(widget.workOrderNumber)
//           .collection('specificWorks')
//           .doc(widget.workId)
//           .set({
//         'pdfUrl': _pdfUrl,
//         'lastUpdated': DateTime.now(),
//       }, SetOptions(merge: true));

//       setState(() {});
//     } catch (e) {
//       print('Error uploading PDF: $e');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   // Download the uploaded PDF file to local storage
//   Future<void> _downloadPdf() async {
//     if (_pdfUrl == null) return;

//     setState(() {
//       isDownloading = true;
//     });

//     try {
//       final response = await http.get(Uri.parse(_pdfUrl!));
//       if (response.statusCode == 200) {
//         final bytes = response.bodyBytes;
//         final dir = await getApplicationDocumentsDirectory();
//         final file = File('${dir.path}/downloaded.pdf');
//         await file.writeAsBytes(bytes);

//         setState(() {
//           _downloadedPdfFile = file;
//         });
//       }
//     } catch (e) {
//       print('Error downloading PDF: $e');
//     } finally {
//       setState(() {
//         isDownloading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload PDF'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             if (isLoading)
//               const Center(child: CircularProgressIndicator())
//             else if (_pdfFile != null)
//               Expanded(
//                 child: SfPdfViewer.file(_pdfFile!),  // Using Syncfusion PDF viewer for local files
//               )
//             else
//               const Center(child: Text('No PDF selected')),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _pickPdf,
//               child: const Text('Pick PDF'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _uploadPdf,
//               child: const Text('Upload PDF'),
//             ),
//             const SizedBox(height: 20),
//             if (_pdfUrl != null) ...[
//               ElevatedButton(
//                 onPressed: _downloadPdf,
//                 child: isDownloading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text('Download PDF'),
//               ),
//               const SizedBox(height: 20),
//               if (_downloadedPdfFile != null)
//                 Expanded(
//                   child: SfPdfViewer.file(_downloadedPdfFile!),  
//                 ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
