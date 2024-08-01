
// // import 'package:cryptel007/Pages/Navigation%20Pages/home_page.dart';
// // import 'package:cryptel007/Pages/Navigation%20Pages/manage_page.dart';
// // import 'package:cryptel007/Pages/Navigation%20Pages/settings_page.dart';
// // import 'package:cryptel007/Tools/colors.dart';
// // import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// // import 'package:flutter/material.dart';

// // class BottomNavPage extends StatefulWidget {
// //   const BottomNavPage({super.key});

// //   @override
// //   State<BottomNavPage> createState() => _BottomNavPageState();
// // }

// // class _BottomNavPageState extends State<BottomNavPage> {
// //   int _selectedIndex = 1;

// //   static const List<Widget> _widgetOptions = <Widget>[
// //     ManagePage(),
// //     HomePage(),
// //     SettingsPage(),
// //   ];

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Center(
// //         child: _widgetOptions.elementAt(_selectedIndex),
// //       ),
// //       bottomNavigationBar: CurvedNavigationBar(
// //         items: const [
// //           Icon(Icons.topic_outlined, color: Colors.white),
// //           Icon(Icons.home_rounded, color: Colors.white),
// //           Icon(Icons.settings_suggest_rounded, color: Colors.white),
// //         ],
// //         color: AppColors.logoblue,
// //         backgroundColor: Colors.transparent,
// //         buttonBackgroundColor: AppColors.logoblue,
// //         height: 60,
// //         animationDuration: const Duration(milliseconds: 300),
// //         index: _selectedIndex,
// //         onTap: (int index) => setState(() {
// //           _selectedIndex = index;
// //         }),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:cryptel007/Pages/Navigation%20Pages/home_page.dart';
// import 'package:cryptel007/Pages/Navigation%20Pages/manage_page.dart';
// import 'package:cryptel007/Pages/Navigation%20Pages/settings_page.dart';
// import 'package:cryptel007/Tools/colors.dart';
// import 'package:google_nav_bar/google_nav_bar.dart';
// import 'package:line_icons/line_icons.dart';

// class BottomNavPage extends StatefulWidget {
//   const BottomNavPage({Key? key}) : super(key: key);

//   @override
//   State<BottomNavPage> createState() => _BottomNavPageState();
// }

// class _BottomNavPageState extends State<BottomNavPage> {
//   int _selectedIndex = 1;

//   static const List<Widget> _widgetOptions = <Widget>[
//     ManagePage(),
//     HomePage(),
//     SettingsPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: AppColors.logoblue,
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 20,
//               color: Colors.black.withOpacity(0.1),
//             )
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
//           child: GNav(
//             rippleColor: Colors.grey[800]!, // tab button ripple color when pressed
//             hoverColor: Colors.grey[700]!, // tab button hover color
//             haptic: true, // haptic feedback
//             tabBorderRadius: 15,
//             tabActiveBorder: Border.all(color: Colors.black, width: 1), // tab button border
//             tabBorder: Border.all(color: Colors.grey, width: 1), // tab button border
//             tabShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 8)], // tab button shadow
//             curve: Curves.easeOutExpo, // tab animation curves
//             duration: Duration(milliseconds: 100), // tab animation duration
//             gap: 8, // the tab button gap between icon and text
//             color: Colors.grey[800], // unselected icon color
//             activeColor: Colors.purple, // selected icon and text color
//             iconSize: 24, // tab button icon size
//             tabBackgroundColor: Colors.purple.withOpacity(0.1), // selected tab background color
//             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5), // navigation bar padding
//             selectedIndex: _selectedIndex,
//             onTabChange: (index) {
//               setState(() {
//                 _selectedIndex = index;
//               });
//             },
//             tabs: [
//               GButton(
//                 icon: LineIcons.cogs,
//                 text: 'Service',
//               ),
//               GButton(
//                 icon: LineIcons.home,
//                 text: 'Home',
//               ),
//               GButton(
//                 icon: LineIcons.user,
//                 text: 'Account',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
