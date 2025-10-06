import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../widgets/Custom_otp_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/success_dialogue.dart';
import '../widgets/gradient_container.dart';
import '../widgets/content_container.dart';
import '../widgets/auth_title.dart';
import '../widgets/resend_row.dart';
import '../widgets/app_logo.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNo;
  const OtpScreen({super.key, required this.phoneNo});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  bool isSmsSelected = true;
  String enteredOtp = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeSmsAutofill();
  }

  Future<void> _initializeSmsAutofill() async {
    await SmsAutoFill().listenForCode;
    await SmsAutoFill().hint;
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }


  @override
  void codeUpdated() {
    final receivedCode = code!;
    if (receivedCode.length == 6) {
      setState(() {
        enteredOtp = receivedCode;
      });
      verifyOtp();
    }
  }

  Future<void> verifyOtp() async {
    if (enteredOtp.isEmpty) {
      _showSnackBar("Please enter the OTP");
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ApiService.verifyOtp(
        phoneNo: widget.phoneNo,
        otpCode: enteredOtp,
      );

      if (result['success']) {
        showSuccessDialog(
          context,
          message: "OTP Verified! Welcome to EasyKaam!.",
        );
      } else {
        _showSnackBar("Error: ${result['message']}");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 50),
              _buildLogo(),
              const SizedBox(height: 30),
              Expanded(child: _buildContentContainer()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() => const AppLogo();

  Widget _buildContentContainer() {
    return ContentContainer(
        child: Column(
          children: [
            const SizedBox(height: 60),
          AuthTitle(
            title: "Enter Verification Code",
            subtitle: "Enter code we've sent to your number via SMS",
          ),
            const SizedBox(height: 50),
            CustomOtpFields(onChanged: (value) => enteredOtp = value),
            const SizedBox(height: 30),
          ResendRow(
            phoneNo: widget.phoneNo,
            isSmsSelected: isSmsSelected,
            onResend: () => _showSnackBar("OTP resent to ${widget.phoneNo}"),
            onToggle: () => setState(() => isSmsSelected = !isSmsSelected),
          ),
            const SizedBox(height: 30),
            AuthButton(
              text: isLoading ? "Verifying..." : "Verify OTP",
              color: const Color(AppConstants.primaryBlue),
              onPressed: isLoading ? null : verifyOtp,
            ),
            const SizedBox(height: 30),
          ],
      ),
    );
  }
}
