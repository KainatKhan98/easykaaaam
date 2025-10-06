import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const SubmitButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity, // default full width
    this.height = 50,             // default height
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25B0F0), // background color
          foregroundColor: Colors.white,             // text color
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 6, // drop shadow
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: Text(text),
      ),
    );
  }
}
