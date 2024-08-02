import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Pages/Core%20Pages/work_detail_page.dart';
import 'package:cryptel007/Pages/Widgets/carousel_widget.dart';
import 'package:cryptel007/Pages/Widgets/company_description.dart'; // Import the new widget
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
    'assets/JBM.png',
    'assets/Con MM.png'
  ];

  Future<void> _login() async {
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
                const SizedBox(height: 10),
                CarouselWidget(
                  imgList: imgList,
                  currentIndex: _current,
                  onPageChanged: (index) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.04, horizontal: MediaQuery.of(context).size.width * 0.04),
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
                    onLogin: _login,
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
    _advancedDrawerController.showDrawer();
  }
}
