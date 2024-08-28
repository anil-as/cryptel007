import 'package:cryptel007/Tools/colors.dart';
import 'package:cryptel007/Tools/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkForm extends StatefulWidget {
  final TextEditingController workOrderController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final VoidCallback onPasswordVisibilityToggle;
  final VoidCallback onClick;

  const WorkForm({
    super.key,
    required this.workOrderController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.onPasswordVisibilityToggle,
    required this.onClick,
  });

  @override
  State<WorkForm> createState() => _WorkFormState();
}

class _WorkFormState extends State<WorkForm> {
  final FocusNode _workOrderFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _workOrderFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double textSize = MediaQuery.of(context).size.width * 0.045;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.width * 0.03,
            horizontal: MediaQuery.of(context).size.width * 0.04,
          ),
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
          child: TextField(
            controller: widget.workOrderController,
            focusNode: _workOrderFocusNode,
            style: TextStyle(
              fontSize: textSize,
              color: AppColors.logoblue,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'Work Order No.',
              labelStyle: TextStyle(
                fontFamily: GoogleFonts.habibi().fontFamily,
                color: AppColors.logoblue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            onSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
          ),
        ),
        const SizedBox(height: 7),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.width * 0.03,
            horizontal: MediaQuery.of(context).size.width * 0.04,
          ),
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
          child: TextField(
            controller: widget.passwordController,
            focusNode: _passwordFocusNode,
            obscureText: !widget.isPasswordVisible,
            style: TextStyle(
              fontSize: textSize,
              color: AppColors.logoblue,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'Password',
              labelStyle: TextStyle(
                color: AppColors.logoblue,
                fontSize: 14,
                fontFamily: GoogleFonts.habibi().fontFamily,
                fontWeight: FontWeight.bold,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  widget.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.logoblue,
                ),
                onPressed: widget.onPasswordVisibilityToggle,
              ),
            ),
            onSubmitted: (_) => widget.onClick(),
          ),
        ),
        const SizedBox(height: 10),
        CustomButton(
          buttonColor: AppColors.logoblue,
          text: 'Enter',
          fsize: 16,
          onPressed: widget.onClick,
          borderRadius: 12,
          suffixIcon: Icons.arrow_right,
        ),
      ],
    );
  }
}
