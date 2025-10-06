import 'package:flutter/material.dart';
import '../../../Customer/home/presentation/pages/home_page.dart';

void showSuccessDialog(BuildContext context, {required String? message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/bottom/Done.png',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 16),
              Text(
                message ?? "Phone Number Verified Successfully.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Welcome to EasyKaam!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff0FB3FF),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Future.delayed(const Duration(seconds: 3), () {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) =>  HomePage()),
    );
  });
}
