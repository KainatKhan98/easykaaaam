import 'package:flutter/material.dart';

class CustomToggle extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String label;

  const CustomToggle({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.label = "SMS",
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 30,
        width: 75,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFAFE1FE) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              right: isSelected ? 2.0 : 47.0,
              top: 2.0,
              child: Container(
                height: 26,
                width: 26,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10.0,
              top: 7.0,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

