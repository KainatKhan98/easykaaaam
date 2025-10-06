import 'package:flutter/material.dart';

class ContentContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ContentContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(60),
          topRight: Radius.circular(60),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
        child: child,
      ),
    );
  }
}

