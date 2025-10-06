import 'package:flutter/material.dart';

class FeeRangeButton extends StatefulWidget {
  const FeeRangeButton({super.key});

  @override
  State<FeeRangeButton> createState() => _FeeRangeButtonState();
}

class _FeeRangeButtonState extends State<FeeRangeButton> {
  bool _isSelected = false;

  void _toggleSelection() {
    setState(() => _isSelected = !_isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _toggleSelection,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: _isSelected
            ? const Color(0x268DD4FD) // 15% opacity
            : Colors.transparent,
        side: const BorderSide(color: Color(0xff8DD4FD)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        _isSelected ? "200-400" : "Visit Fee Range",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xff0F0F0F),
        ),
      ),
    );
  }
}
