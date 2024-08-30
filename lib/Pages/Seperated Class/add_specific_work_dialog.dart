import 'package:cryptel007/Tools/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class AddWorkDialogContent extends StatefulWidget {
  final String workOrderNumber;
  const AddWorkDialogContent({super.key, required this.workOrderNumber});

  @override
  _AddWorkDialogContentState createState() => _AddWorkDialogContentState();
}

class _AddWorkDialogContentState extends State<AddWorkDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController rawmaterialController = TextEditingController();
  final TextEditingController rmsizeController = TextEditingController();
  final TextEditingController rmcController = TextEditingController();
  final TextEditingController machineController = TextEditingController();
  final TextEditingController operatorController = TextEditingController();
  final TextEditingController workcenterController = TextEditingController();
  final TextEditingController drawingnumberController = TextEditingController();
  final TextEditingController expectedDeliveryDateController =
      TextEditingController();
  DateTime? selectedDate;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? currentDate,
      firstDate: currentDate, // Restrict to only future dates including today
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        expectedDeliveryDateController.text =
            DateFormat('dd-MMMM-yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
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
      _imageFile = image != null ? File(image.path) : null;
    });
  }

  Future<String?> _uploadImage(String id) async {
    if (_imageFile == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('SpecificWorkImages/${widget.workOrderNumber}/$id.jpg');
      await storageRef.putFile(_imageFile!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      return null;
    }
  }

  Future<void> _saveWork() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });
      final name = nameController.text;
      final id = idController.text;
      final quantity = quantityController.text;
      final expectedDeliveryDate = expectedDeliveryDateController.text;
      final rawmaterial = rawmaterialController.text;
      final rmsize = rmsizeController.text;
      final rmc = rmcController.text;
      final machine = machineController.text;
      final operators = operatorController.text;
      final workcenter = workcenterController.text;
      final drawingnumber = drawingnumberController;

      String? imageUrl = await _uploadImage(id);

      try {
        await FirebaseFirestore.instance
            .collection('works')
            .doc(widget.workOrderNumber)
            .collection('specificWorks')
            .doc(id)
            .set({
          'name': name,
          'id': id,
          'drawingnumber':drawingnumber,
          'rawmaterial': rawmaterial,
          'rmsize': rmsize,
          'rmc': rmc,
          'operator': operators,
          'machine': machine,
          'workcenter': workcenter,
          'quantity': quantity,
          'completion': '0',
          'expectedDeliveryDate': expectedDeliveryDate,
          'imageUrl': imageUrl,
          'lastedit': '',
        });

        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Work added successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
      bool readOnly = false,
      IconData? suffixIcon,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        ),
        keyboardType: keyboardType,
        readOnly: readOnly,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Specify Work',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.logoblue,
                      fontFamily: GoogleFonts.strait().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.add_a_photo_rounded),
                            label: const Text('Add Image'),
                          ),
                          if (_imageFile != null) ...[
                            const SizedBox(height: 8),
                            Image.file(
                              _imageFile!,
                              height: 200,
                              width: MediaQuery.of(context).size.width * 0.7,
                              fit: BoxFit.cover,
                            ),
                          ],
                          const SizedBox(height: 8),
                          _buildTextField(
                            'ID',
                            idController,
                            suffixIcon: Icons.tag,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an ID';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            'Name',
                            nameController,
                            suffixIcon: Icons.settings_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            'Drawing Number',
                            drawingnumberController,
                            suffixIcon: Icons.draw_rounded,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Drawing Number';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            'Raw Material',
                            rawmaterialController,
                            suffixIcon: Icons.integration_instructions_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the Raw Material';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            'Raw Material Size',
                            rmsizeController,
                            suffixIcon: Icons.photo_size_select_small_rounded,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Material Specification';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            'RMC',
                            rmcController,
                            suffixIcon: Icons.note_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter RMC';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            'Machine',
                            machineController,
                            suffixIcon: Icons.devices_other,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the Machine allotted';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            'Operator',
                            operatorController,
                            suffixIcon: Icons.engineering,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Operators allotted';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            'Work Center',
                            workcenterController,
                            suffixIcon: Icons.factory,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter center allotted for this work operations';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            'Quantity',
                            quantityController,
                            keyboardType: TextInputType.number,
                            suffixIcon: Icons.format_list_numbered,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a quantity';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: AbsorbPointer(
                              child: _buildTextField(
                                'Expected Delivery Date',
                                expectedDeliveryDateController,
                                keyboardType: TextInputType.datetime,
                                readOnly: true,
                                suffixIcon: Icons.calendar_today,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a delivery date';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: ElevatedButton(
                        onPressed: _saveWork,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.logoblue,
                          minimumSize: const Size(400, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontFamily: GoogleFonts.strait().fontFamily,
                            fontSize: 19,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
