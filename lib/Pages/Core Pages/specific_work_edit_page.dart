import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Pages/Core%20Pages/specific_work_page.dart';
import 'package:cryptel007/Pages/Seperated%20Class/date_field.dart';
import 'package:cryptel007/Pages/Seperated%20Class/delete_confirmation_dialog.dart';
import 'package:cryptel007/Pages/Seperated%20Class/image_section.dart';
import 'package:cryptel007/Pages/Seperated%20Class/percentage_selector.dart';
import 'package:cryptel007/Pages/Seperated%20Class/quantity_field.dart';
import 'package:cryptel007/Pages/Seperated%20Class/save_confirmation_dialog.dart';
import 'package:cryptel007/Pages/Seperated%20Class/text_field.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cryptel007/Tools/colors.dart';

class SpecificWorkEditPage extends StatefulWidget {
  final String workOrderNumber;
  final String workId;

  const SpecificWorkEditPage({
    super.key,
    required this.workOrderNumber,
    required this.workId,
  });

  @override
  _SpecificWorkEditPageState createState() => _SpecificWorkEditPageState();
}

class _SpecificWorkEditPageState extends State<SpecificWorkEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _expectedDateController = TextEditingController();
  final TextEditingController _completionController = TextEditingController();
  final TextEditingController rawmaterialController = TextEditingController();
  final TextEditingController rmsizeController = TextEditingController();
  final TextEditingController rmcController = TextEditingController();
  final TextEditingController machineController = TextEditingController();
  final TextEditingController operatorController = TextEditingController();
  final TextEditingController workcenterController = TextEditingController();
  final TextEditingController drawingnumberController = TextEditingController();
  File? _imageFile;
  String? _imageUrl;
  int _quantity = 0;
  DateTime _expectedDate = DateTime.now();
  double _completion = 0.0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWorkDetails();
  }

  Future<void> _fetchWorkDetails() async {
    setState(() {
      isLoading = true;
    });
    final doc = await FirebaseFirestore.instance
        .collection('works')
        .doc(widget.workOrderNumber)
        .collection('specificWorks')
        .doc(widget.workId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _quantity = int.tryParse(data['quantity'] ?? '0') ?? 0;
        rawmaterialController.text = data['rawmaterial'] ?? '';
        rmsizeController.text = data['rmsize'] ?? '';
        rmcController.text = data['rmc'] ?? '';
        machineController.text = data['machine'] ?? '';
        workcenterController.text = data['workcenter'] ?? '';
        operatorController.text = data['operator'] ?? '';
        drawingnumberController.text = data['drawingnumber'] ?? '';
        _expectedDate = DateTime.tryParse(data['expectedDeliveryDate'] ?? '') ??
            DateTime.now();
        _completion = double.tryParse(data['completion'] ?? '0') ?? 0.0;
        _completionController.text = _completion.toString();
        _expectedDateController.text =
            DateFormat('dd-MMMM-yyyy').format(_expectedDate);
        _imageUrl = data['imageUrl'] ?? '';
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _updateWorkDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      print('Starting update work details');
      if (_imageFile != null) {
        setState(() {
          isLoading = true;
        });
        final storageRef = FirebaseStorage.instance.ref().child(
            'SpecificWorkImages/${widget.workOrderNumber}/$widget.workId.jpg');
        await storageRef.putFile(_imageFile!);
        _imageUrl = await storageRef.getDownloadURL();
      }
      await FirebaseFirestore.instance
          .collection('works')
          .doc(widget.workOrderNumber)
          .collection('specificWorks')
          .doc(widget.workId)
          .update({
        'name': _nameController.text,
        'quantity': _quantity.toString(),
        'drawingnumber': drawingnumberController.text,
        'operator': operatorController.text,
        'rawmaterial': rawmaterialController.text,
        'rmsize': rmsizeController.text,
        'rmc': rmcController.text,
        'machine': machineController.text,
        'workcenter': workcenterController.text,
        'expectedDeliveryDate':
            DateFormat('dd-MMMM-yyyy').format(_expectedDate),
        'completion': _completion.toString(),
        'lastedit': DateFormat('dd-MMMM-yyyy HH:mm:ss').format(DateTime.now()),
        'imageUrl': _imageUrl,
      });
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              SpecificWorkPage(workOrderNumber: widget.workOrderNumber),
        ),
      );
    }
  }

  Future<void> _deleteWork() async {
    await FirebaseFirestore.instance
        .collection('works')
        .doc(widget.workOrderNumber)
        .collection('specificWorks')
        .doc(widget.workId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Work Details',
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.green),
            onPressed: () =>
                showSaveConfirmationDialog(context, _updateWorkDetails),
            color: AppColors.logoblue,
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: Colors.red),
            onPressed: () => showDeleteConfirmationDialog(context, _deleteWork),
            color: AppColors.logoblue,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    ImageSection(
                      imageFile: _imageFile,
                      imageUrl: _imageUrl,
                      pickImage: _pickImage,
                    ),
                    TextFieldWidget(
                        controller: _nameController,
                        label: 'Work Name',
                        hint: 'Enter the work name'),
                    TextFieldWidget(
                        controller: rawmaterialController,
                        label: 'Raw Material',
                        hint: 'Enter Raw Materials used'),
                    TextFieldWidget(
                        controller: rmsizeController,
                        label: 'Raw Material Size',
                        hint: 'Enter Size Specification of Material'),
                    TextFieldWidget(
                        controller: rmcController,
                        label: 'RMC',
                        hint: 'Enter RMC'),
                    TextFieldWidget(
                        controller: machineController,
                        label: 'Machine',
                        hint: 'Enter Machine allotted'),
                    TextFieldWidget(
                        controller: drawingnumberController,
                        label: 'Drawing Number',
                        hint: 'Enter Drawing Number'),
                          TextFieldWidget(
                        controller: operatorController,
                        label: 'Operators',
                        hint: 'Enter Operators allotted'),
                    TextFieldWidget(
                        controller: workcenterController,
                        label: 'Work Center',
                        hint: 'Enter Operating Center'),const SizedBox(
                      height: 10,
                    ),
                    DateField(
                      controller: _expectedDateController,
                      initialDate: _expectedDate,
                      onDateSelected: (pickedDate) {
                        setState(() {
                          _expectedDate = pickedDate;
                          _expectedDateController.text =
                              DateFormat('yyyy-MM-dd').format(_expectedDate);
                        });
                      },
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    QuantityField(
                      quantity: _quantity,
                      onDecrease: () {
                        setState(() {
                          if (_quantity > 0) _quantity--;
                        });
                        _quantityController.text = _quantity.toString();
                      },
                      onIncrease: () {
                        setState(() {
                          _quantity++;
                        });
                        _quantityController.text = _quantity.toString();
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    PercentageSelector(
                      completion: _completion,
                      onChanged: (value) {
                        setState(() {
                          _completion = value;
                          _completionController.text = value.toStringAsFixed(0);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }
}
