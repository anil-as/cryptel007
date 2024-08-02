import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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

  int _quantity = 0;
  DateTime _expectedDate = DateTime.now();
  double _completion = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchWorkDetails();
  }

  Future<void> _fetchWorkDetails() async {
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
        _expectedDate = DateTime.tryParse(data['expectedDeliveryDate'] ?? '') ?? DateTime.now();
        _completion = double.tryParse(data['completion'] ?? '0') ?? 0.0;
        _completionController.text = _completion.toString();
        _expectedDateController.text = DateFormat('dd-MMMM-yyyy').format(_expectedDate);
      });
    }
  }

  Future<void> _updateWorkDetails() async {
  if (_formKey.currentState?.validate() ?? false) {
    await FirebaseFirestore.instance
        .collection('works')
        .doc(widget.workOrderNumber)
        .collection('specificWorks')
        .doc(widget.workId)
        .update({
      'name': _nameController.text,
      'quantity': _quantity.toString(),
      'expectedDeliveryDate': DateFormat('dd-MMMM-yyyy').format(_expectedDate),
      'completion': _completion.toString(),
      'lastedit': DateFormat('dd-MMMM-yyyy HH:mm:ss').format(DateTime.now()), // Add this line
    });

    Navigator.pop(context);
  }
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
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _updateWorkDetails,
            color: AppColors.logoblue,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Work Name',
                hint: 'Enter the work name',
              ),
              const SizedBox(height: 20),
              _buildQuantityField(),
              const SizedBox(height: 20),
              _buildDateField(),
              const SizedBox(height: 20),
              _buildPercentageSelector(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateWorkDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.logoblue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: validator,
        ),
      ],
    );
  }

 Widget _buildQuantityField() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          'Quantity',
          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: AppColors.logoblue),
            onPressed: () {
              setState(() {
                if (_quantity > 0) _quantity--;
              });
              _quantityController.text = _quantity.toString();
            },
          ),
          SizedBox(
            width: 60,
            child: Text(
              _quantity.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.logoblue),
            onPressed: () {
              setState(() {
                _quantity++;
              });
              _quantityController.text = _quantity.toString();
            },
          ),
        ],
      ),
    ],
  );
}


  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expected Delivery Date',
          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _expectedDateController,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            hintText: 'Enter the expected delivery date',
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today, color: AppColors.logoblue),
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _expectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != _expectedDate) {
                  setState(() {
                    _expectedDate = picked;
                    _expectedDateController.text = DateFormat('yyyy-MM-dd').format(_expectedDate);
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPercentageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completion Percentage',
          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final radius = maxWidth * 0.3;
            return Column(
              children: [
                CircularPercentIndicator(
                  radius: radius,
                  lineWidth: 15.0,
                  animation: true,
                  percent: _completion / 100,
                  center: Text(
                    '${_completion.toStringAsFixed(0)}%',
                    style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: AppColors.logoblue,
                  backgroundColor: Colors.lightBlueAccent,
                ),
                const SizedBox(height: 20),
                Slider(
                  value: _completion,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (value) {
                    setState(() {
                      _completion = value;
                      _completionController.text = value.toStringAsFixed(0);
                    });
                  },
                  activeColor: AppColors.logoblue,
                  inactiveColor: Colors.grey[400],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
