import 'package:flutter/material.dart';

class WorkerSearchBar extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onTap;

  const WorkerSearchBar({
    super.key,
    this.hintText = "Search location...",
    this.prefixIcon = Icons.location_on,
    this.suffixIcon = Icons.more_horiz,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width - 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black54),
            border: InputBorder.none,
            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFFADD8E6),
            ),
            suffixIcon: suffixIcon != null
                ? Icon(
                    suffixIcon,
                    color: Colors.black54,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

