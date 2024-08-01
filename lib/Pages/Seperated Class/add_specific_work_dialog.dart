import 'package:cryptel007/Tools/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController completionController =
      TextEditingController(text: '0');
  final TextEditingController expectedDeliveryDateController =
      TextEditingController();
  DateTime? selectedDate;

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

  Future<void> _saveWork() async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = nameController.text;
      final id = idController.text;
      final quantity = quantityController.text;
      final completion = completionController.text;
      final expectedDeliveryDate = expectedDeliveryDateController.text;

      try {
        await FirebaseFirestore.instance
            .collection('works')
            .doc(widget.workOrderNumber)
            .collection('specificWorks')
            .doc(id)
            .set({
          'name': name,
          'id': id,
          'quantity': quantity,
          'completion': completion,
          'expectedDeliveryDate': expectedDeliveryDate,
          'lastedit':'',
        });

        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Work added successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      _buildTextField(
                        'Completion %',
                        completionController,
                        keyboardType: TextInputType.number,
                        suffixIcon: Icons.percent,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the completion percentage';
                          }
                          if (double.tryParse(value) == null ||
                              double.tryParse(value)! < 0 ||
                              double.tryParse(value)! > 100) {
                            return 'Please enter a valid percentage between 0 and 100';
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
    );
  }
}
