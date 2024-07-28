import 'package:cryptel007/Pages/Core Pages/work_detail_page.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:cryptel007/Tools/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddWorkPage extends StatefulWidget {
  const AddWorkPage({super.key});

  @override
  _AddWorkPageState createState() => _AddWorkPageState();
}

class _AddWorkPageState extends State<AddWorkPage> {
  final _formKey = GlobalKey<FormState>();

  String _workOrderNumber = '';
  String _password = '';
  final DateTime _creationDate = DateTime.now();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final List<Map<String, String>> _contacts = [];

  void _addContact() {
    final name = _contactNameController.text;
    final number = _contactNumberController.text;
    if (name.isNotEmpty && number.isNotEmpty) {
      setState(() {
        _contacts.add({'name': name, 'number': number});
        _contactNameController.clear();
        _contactNumberController.clear();
      });
    }
  }

  void _removeContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      final workData = {
        'WorkTitle': _workOrderNumber,
        'WorkDescription': _password,
        'workOrderNumber': _workOrderNumber,
        'creationDate': _creationDate,
        'contacts': _contacts,
        'password': _password
      };

      // Save data to 'work' collection
      await FirebaseFirestore.instance
          .collection('work')
          .doc(_workOrderNumber)
          .set(workData);

      // Create subcollection 'jobcard' and add a document with workOrderNumber as the ID
      await FirebaseFirestore.instance
          .collection('work')
          .doc(_workOrderNumber)
          .collection('jobcard')
          .doc(_workOrderNumber)
          .set({
        'status': 'Initialized', // Add any default data if needed
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data successfully saved')),
      );

      // Navigate to WorkDetailPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              WorkDetailPage(workOrderNumber: _workOrderNumber),
        ),
      );
    }
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
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Work Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Work title';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _workOrderNumber = value; // Ensure workOrderNumber is set
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Work Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Work description';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _password = value; // Ensure password is set
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Work Order Number',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _workOrderNumber = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the work order number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Creation Date: ${DateFormat('yyyy-MM-dd – kk:mm').format(_creationDate)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Contact Info',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contactNameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contactNumberController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              CustomButton(
                buttonColor: Colors.white,
                textColor: Colors.black,
                text: 'Add Contact',
                suffixIcon: Icons.add,
                iconColor: AppColors.logoblue,
                onPressed: _addContact,
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          contact['name']![0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        contact['name']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        contact['number']!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeContact(index),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: CustomButton(
                  borderRadius: 22,
                  h: 70,
                  text: 'Create',
                  fsize: 24,
                  onPressed: _saveData,
                  buttonColor: AppColors.logoblue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
