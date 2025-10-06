import 'package:flutter/material.dart';

class PostJobSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String text;

  const PostJobSubmitButton({
    super.key,
    required this.isLoading,
    this.onPressed,
    this.text = "Submit Request",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading 
              ? Colors.grey 
              : const Color(0xff25B0F0),
          minimumSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }
}

