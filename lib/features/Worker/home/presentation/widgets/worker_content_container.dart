import 'package:flutter/material.dart';

class WorkerContentContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const WorkerContentContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: child,
    );
  }
}

