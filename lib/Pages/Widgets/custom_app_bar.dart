import 'package:cryptel007/Tools/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AdvancedDrawerController advancedDrawerController;
  final VoidCallback onMenuButtonPressed;

  const CustomAppBar({
    Key? key,
    required this.advancedDrawerController,
    required this.onMenuButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: onMenuButtonPressed,
        icon: ValueListenableBuilder<AdvancedDrawerValue>(
          valueListenable: advancedDrawerController,
          builder: (_, value, __) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Image.asset(
                'assets/app-drawer.png',
                color: AppColors.logoblue,
                key: ValueKey<bool>(value.visible),
              ),
            );
          },
        ),
      ),
      title: Text(
        'CRYPTEL',
        style: TextStyle(
          fontFamily: GoogleFonts.roboto().fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: AppColors.logoblue,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
