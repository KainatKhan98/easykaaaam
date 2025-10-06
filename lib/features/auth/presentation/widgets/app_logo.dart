import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double height;
  final double width;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.height = 145,
    this.width = 259,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        "assets/logo/logo.png",
        height: height,
        width: width,
        fit: fit,
      ),
    );
  }
}

