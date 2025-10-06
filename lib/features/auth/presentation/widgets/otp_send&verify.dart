import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../widgets/success_dialogue.dart';

class VerifyAndSend {
  /// Verifies OTP
  static Future<void> verifyOtp({
    required BuildContext context,
    required String phoneNo,
    required String enteredOtp,
  }) async {
    if (enteredOtp.isEmpty) {
      _showSnackBar(context, "Please enter the OTP");
      return;
    }

    try {
      debugPrint("📨 Starting OTP verification...");
      debugPrint("👉 Entered OTP: $enteredOtp");
      debugPrint("👉 Phone No: $phoneNo");

      final result = await ApiService.verifyOtp(
        phoneNo: phoneNo,
        otpCode: enteredOtp,
      );

      debugPrint("📥 API Result: $result");

      if (result['success']) {
        debugPrint("🎉 OTP Verified Successfully!");
        debugPrint("🔑 JWT Token: ${result['token']}");
        debugPrint("🔄 Refresh Token: ${result['refreshToken']}");
        debugPrint("👤 User ID: ${result['userId']}");

        showSuccessDialog(
          context,
          message: "OTP Verified! Welcome to EasyKaam!\n\nTokens stored securely.",
        );
      } else {
        debugPrint("❌ OTP Verification Failed: ${result['message']}");
        _showSnackBar(context, "Error: ${result['message']}");
      }
    } catch (e, stack) {
      debugPrint("🚨 Error in verifyOtp: $e");
      debugPrint("🪲 StackTrace: $stack");
      _showSnackBar(context, "Error: $e");
    }
  }

  /// Resends OTP
  static Future<void> resendOtp({
    required BuildContext context,
    required String phoneNo,
  }) async {
    _showSnackBar(context, "Resending OTP to $phoneNo...");

    try {
      final phoneWithoutPlus = phoneNo.startsWith("+")
          ? phoneNo.substring(1)
          : phoneNo;

      debugPrint("📡 Resending OTP to $phoneWithoutPlus");

      final result = await ApiService.sendOtp("User", phoneWithoutPlus);

      if (result['success']) {
        _showSnackBar(context, "OTP resent to $phoneNo");
        debugPrint("✅ OTP resent successfully");
      } else {
        _showSnackBar(context, "Failed to resend OTP: ${result['message']}");
        debugPrint("❌ Resend OTP failed: ${result['message']}");
      }
    } catch (e, stack) {
      debugPrint("🚨 Error in resendOtp: $e");
      debugPrint("🪲 StackTrace: $stack");
      _showSnackBar(context, "Error: $e");
    }
  }

  /// Snackbar helper
  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }



}
