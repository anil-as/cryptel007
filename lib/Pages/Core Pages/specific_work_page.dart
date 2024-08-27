import 'package:cryptel007/Pages/Core%20Pages/specific_work_edit_page.dart';
import 'package:cryptel007/Pages/Core%20Pages/work_detail_page.dart';
import 'package:cryptel007/Pages/Seperated%20Class/add_specific_work_dialog.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:cryptel007/Tools/user_role_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

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

  void _navigateToEditPage(String workId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpecificWorkEditPage(
          workOrderNumber: widget.workOrderNumber,
          workId: workId,
        ),
      ),
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
              Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              WorkDetailPage(workOrderNumber: widget.workOrderNumber),
        ),
      );
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
        actions: [
          if (_userRole == 'ADMIN' ||
              _userRole == 'Manager' ||
              _userRole == 'Editor')
            IconButton(
                icon: Image.asset('assets/add.png'), onPressed: _showAddWorkDialog),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
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
                    final name = (doc['name'] ?? '').toUpperCase();
                    final completion = (doc['completion'] ?? '0') as String;
                    final quantity = doc['quantity'] ?? '';
                    final expectedDeliveryDate = doc['expectedDeliveryDate'] ?? '';
                    final id = doc['id'] ?? '';
                    final lastEdit = doc['lastedit'] ?? ''; // Fetch last edit timestamp
                    final imageUrl = doc['imageUrl'] ?? ''; // Image URL from Firestore
                    final itemNumber = index + 1;

                    return GestureDetector(
                      onTap: () {
                        if (_userRole == 'ADMIN' ||
                            _userRole == 'Manager' ||
                            _userRole == 'Editor') {
                          _navigateToEditPage(id);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.grey
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Add Image as Prefix
                                  if (imageUrl.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
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
                                        const SizedBox(height: 8),
                                        Text(
                                          'Last Edited On: ${lastEdit.isNotEmpty ? lastEdit : 'Not Available'}',
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 2,
                              left: 2,
                              child: Container(
                                width: 20,
                                height: 20,
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
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildPercentageIndicator(String percentage) {
    final double percentValue = double.tryParse(percentage) ?? 0;
    final Color color = _getColorForPercentage(percentValue);

    return SizedBox(
      width: double.infinity,
      child: LinearPercentIndicator(
        lineHeight: 20.0,
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
      return Colors.red;
    } else if (percentage < 70) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
