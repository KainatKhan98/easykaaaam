import 'package:flutter/material.dart';
import 'custom_toggle.dart';

class ResendRow extends StatelessWidget {
  final String phoneNo;
  final bool isSmsSelected;
  final VoidCallback onResend;
  final VoidCallback onToggle;

  const ResendRow({
    super.key,
    required this.phoneNo,
    required this.isSmsSelected,
    required this.onResend,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Didn't get the code?",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onResend,
              child: const Text(
                "Resend it.",
                style: TextStyle(
                  color: Colors.lightBlue,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(width: 12),
            CustomToggle(
              isSelected: isSmsSelected,
              onTap: onToggle,
            ),
          ],
        ),
      ],
    );
  }
}

