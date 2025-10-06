import 'package:flutter/material.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/logo/logo.png",
      height: 750, // adjust for better UI
      width: 350,
    );
  }
}
