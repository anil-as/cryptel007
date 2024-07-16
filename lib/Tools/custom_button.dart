import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color buttonColor;
  final Color hoverColor;
  final Color textColor;
  final double borderRadius;
  final double fsize;
  final double iconsize;
  final double h;
  final double w;
  final IconData? suffixIcon;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.buttonColor = Colors.blue,
    this.hoverColor = Colors.grey,
    this.textColor = Colors.white,
    this.fsize = 19,
    this.iconsize = 24,
    this.borderRadius = 4.0,
    this.h = 50,
    this.w = double.infinity,
    this.suffixIcon,
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isHovered ? widget.hoverColor : widget.buttonColor,
          foregroundColor: widget.textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          minimumSize: Size(widget.w, widget.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.text,
              style: TextStyle(
                fontSize: widget.fsize,
                fontFamily: 'Strait',
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.suffixIcon != null)
              SizedBox(
                width: 24,
                child: Icon(widget.suffixIcon, size: widget.iconsize),
              ),
          ],
        ),
      ),
    );
  }
}
