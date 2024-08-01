import 'package:cryptel007/Pages/Seperated%20Class/add_specific_work_dialog.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:cryptel007/Tools/user_role_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class SpecificWorkPage extends StatefulWidget {
  final String workOrderNumber;
  const SpecificWorkPage({super.key, required this.workOrderNumber});

  @override
  _SpecificWorkPageState createState() => _SpecificWorkPageState();
}

class _SpecificWorkPageState extends State<SpecificWorkPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserRoleService _userRoleService = UserRoleService();
  GoogleSignInAccount? _currentUser;
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
        _isLoading = true;
      });
      _fetchUserRole(account?.email);
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _fetchUserRole(String? email) async {
    if (email == null) return;

    final role = await _userRoleService.fetchUserRole(email);

    if (mounted) {
      setState(() {
        _userRole = role;
        _isLoading = false;
      });
    }
  }

  void _showAddWorkDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AddWorkDialogContent(workOrderNumber: widget.workOrderNumber);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('assets/arrow.png'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Work Status',
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('works')
            .doc(widget.workOrderNumber)
            .collection('specificWorks')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final doc = data[index];
              final name = (doc['name'] ?? '')
                  .toUpperCase(); // Convert name to uppercase
              final completion = (doc['completion'] ?? '0') as String;
              final quantity = doc['quantity'] ?? '';
              final expectedDeliveryDate = doc['expectedDeliveryDate'] ?? '';
              final id = doc['id'] ?? '';
              final itemNumber = index + 1; // Ordered number starts from 1

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8BC6EC), 
                      Color(0xFF9599E2), 
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing:
                                        1.2, // Add some letter spacing for better readability
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Expected Delivery Date',
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.logoblue,
                                    ),
                                  ),
                                  Text(
                                    expectedDeliveryDate,
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ID: $id',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Quantity: $quantity',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildPercentageIndicator(completion),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 2, // Adjusted position
                      left: 2, // Adjusted position
                      child: Container(
                        width: 20, // Adjusted size
                        height: 20, // Adjusted size
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            itemNumber.toString(),
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          _userRole == 'ADMIN' // Only show the button if the role is 'ADMIN'
              ? FloatingActionButton(
                  onPressed: _showAddWorkDialog,
                  child: const Icon(Icons.add),
                  backgroundColor: Colors.yellow,
                )
              : null,
    );
  }

  Widget _buildPercentageIndicator(String percentage) {
    final double percentValue = double.tryParse(percentage) ?? 0;
    final Color color = _getColorForPercentage(percentValue);

    return Container(
      width: double.infinity, // Full width of the container
      child: LinearPercentIndicator(
        lineHeight: 20.0, // Height of the indicator
        percent: percentValue / 100,
        backgroundColor: Colors.grey[300]!,
        progressColor: color,
        center: Text(
          '${percentValue.toStringAsFixed(0)}%',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        barRadius: const Radius.circular(8),
      ),
    );
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage < 30) {
      return Colors.red; // Critical
    } else if (percentage < 70) {
      return Colors.orange; // Warning
    } else {
      return Colors.green; // Good
    }
  }
}
