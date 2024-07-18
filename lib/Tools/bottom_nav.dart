
import 'package:cryptel007/Pages/Navigation%20Pages/home_page.dart';
import 'package:cryptel007/Pages/Navigation%20Pages/manage_page.dart';
import 'package:cryptel007/Pages/Navigation%20Pages/settings_page.dart';
import 'package:cryptel007/Tools/colors.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int _selectedIndex = 1;

  static const List<Widget> _widgetOptions = <Widget>[
    ManagePage(),
    HomePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        items: const [
          Icon(Icons.topic_outlined, color: Colors.white),
          Icon(Icons.home_rounded, color: Colors.white),
          Icon(Icons.settings_suggest_rounded, color: Colors.white),
        ],
        color: AppColors.logoblue,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: AppColors.logoblue,
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex,
        onTap: (int index) => setState(() {
          _selectedIndex = index;
        }),
      ),
    );
  }
}