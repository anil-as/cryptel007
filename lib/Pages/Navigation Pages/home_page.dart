import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Pages/Core%20Pages/work_detail_page.dart';
import 'package:cryptel007/Pages/Widgets/company_description.dart';
import 'package:cryptel007/Pages/Widgets/custom_app_bar.dart';
import 'package:cryptel007/Pages/Widgets/work_search_form.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:cryptel007/Tools/drawer_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _workOrderController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _advancedDrawerController = AdvancedDrawerController();
  int _current = 0;

  final List<String> imgList = [
    'assets/4axis.png',
    'assets/3axiscnc.png',
    'assets/cnc200.png',
    'assets/cnclathee.png',
    'assets/cnccmm.png',
    'assets/Con MM.png'
  ];

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      setState(() {
        _current = (_current + 1) % imgList.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _workOrderController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final workOrderNumber = _workOrderController.text;
    final password = _passwordController.text;

    if (workOrderNumber.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final docRef = _firestore.collection('works').doc(workOrderNumber);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      if (password == data['PASSWORD']) {
        _workOrderController.clear();
        _passwordController.clear();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkDetailPage(
              workOrderNumber: workOrderNumber,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid work order number or password')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Work order not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdrop: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.logoblue, Colors.white],
          ),
        ),
      ),
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      drawer: const DrawerMenu(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          advancedDrawerController: _advancedDrawerController,
          onMenuButtonPressed: _handleMenuButtonPressed,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CompanyDescription(),
                const SizedBox(height: 17),

                // Photo Slider
                Container(
                  height: MediaQuery.of(context).size.width * 0.5,
                  child: PageView.builder(
                    itemCount: imgList.length,
                    controller: PageController(viewportFraction: 2),
                    onPageChanged: (index) {
                      setState(() {
                        _current = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: PageController(viewportFraction: 0.8),
                        builder: (context, child) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                imgList[_current],
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 17),

                // WorkForm
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.width * 0.04,
                      horizontal: MediaQuery.of(context).size.width * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: WorkForm(
                    workOrderController: _workOrderController,
                    passwordController: _passwordController,
                    isPasswordVisible: _isPasswordVisible,
                    onPasswordVisibilityToggle: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    onClick: _search,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuButtonPressed() {
    // FocusScope.of(context).unfocus();
    _advancedDrawerController.showDrawer();
  }
}
