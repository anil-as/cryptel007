import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CertificationPage extends StatefulWidget {
  final String workOrderNumber;

  const CertificationPage({super.key, required this.workOrderNumber});

  @override
  _CertificationPageState createState() => _CertificationPageState();
}

class _CertificationPageState extends State<CertificationPage> {
  File? _certificateImage;
  bool _isCertificateUploaded = false;
  String? _uploadedImageUrl;
  bool _isLoading = true;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _fetchCertificate();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _fetchUserRole(account?.email);
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _fetchUserRole(String? email) async {
    if (email == null) return;

    try {
      // Fetch the user role from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userRole = userDoc['role']; // Assuming 'role' is a field in your Firestore user document
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user role: $e')),
      );
    }
  }

  Future<void> _fetchCertificate() async {
    try {
      var certificatesCollection = FirebaseFirestore.instance
          .collection('works')
          .doc(widget.workOrderNumber)
          .collection('certificates');

      var snapshot = await certificatesCollection.get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _isCertificateUploaded = true;
          _uploadedImageUrl = snapshot.docs.first['certificateUrl'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch certificate: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _certificateImage = File(pickedFile.path);
      });

      bool? confirmUpload = await _showUploadConfirmationDialog();
      if (confirmUpload == true) {
        _uploadCertificate();
      }
    }
  }

  Future<void> _uploadCertificate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String storagePath =
          'workcertifications/${widget.workOrderNumber}/certificate_${DateTime.now().millisecondsSinceEpoch}.jpg';

      UploadTask uploadTask =
          FirebaseStorage.instance.ref(storagePath).putFile(_certificateImage!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('works')
          .doc(widget.workOrderNumber)
          .collection('certificates')
          .add({'certificateUrl': downloadUrl, 'uploadedAt': Timestamp.now()});

      setState(() {
        _isCertificateUploaded = true;
        _uploadedImageUrl = downloadUrl;
        _certificateImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certificate uploaded successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload certificate: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCertificate() async {
    bool? confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseStorage.instance.refFromURL(_uploadedImageUrl!).delete();

      var certificatesCollection = FirebaseFirestore.instance
          .collection('works')
          .doc(widget.workOrderNumber)
          .collection('certificates');

      var snapshot = await certificatesCollection
          .where('certificateUrl', isEqualTo: _uploadedImageUrl)
          .get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _isCertificateUploaded = false;
        _uploadedImageUrl = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certificate deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete certificate: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool?> _showUploadConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Upload Confirmation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to upload this certificate?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              _certificateImage != null
                  ? SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.file(
                        _certificateImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Upload',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Confirmation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete this certificate?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
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
        title: const Text("Certification"),
        leading: IconButton(
          icon: Image.asset('assets/arrow.png'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: AppColors.logoblue,
            ))
          : Center(
              child: _isCertificateUploaded && _uploadedImageUrl != null
                  ? Stack(
                      children: [
                        Center(
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 1.0,
                            maxScale: 5.0,
                            child: AspectRatio(
                              aspectRatio: 1 / 1,
                              child: Image.network(
                                _uploadedImageUrl!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        if (_userRole == 'ADMIN' ||
                            _userRole == 'Manager' ||
                            _userRole == 'Editor')
                          Positioned(
                            top: 20,
                            right: 20,
                            child: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 30),
                              onPressed: _deleteCertificate,
                            ),
                          ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 100,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Upload Certificate'),
                        ),
                      ],
                    ),
            ),
    );
  }
}
