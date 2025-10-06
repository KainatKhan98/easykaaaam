import 'package:flutter/material.dart';

class PostJobGradientContainer extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const PostJobGradientContainer({
    super.key,
    required this.child,
    this.colors = const [Color(0xFF8DD4FD), Color(0xFF547F97)],
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
          stops: const [0.01, 1.0],
        ),
      ),
      child: child,
    );
  }
}

