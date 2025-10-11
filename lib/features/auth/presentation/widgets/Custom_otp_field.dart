import 'package:flutter/material.dart';

class CustomOtpFields extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const CustomOtpFields({super.key, this.onChanged});

  @override
  State<CustomOtpFields> createState() => _CustomOtpFieldsState();
}

class _CustomOtpFieldsState extends State<CustomOtpFields> {
  final int fieldCount = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(fieldCount, (_) => TextEditingController());
    _focusNodes = List.generate(fieldCount, (_) => FocusNode());
    debugPrint("📨 OTP fields initialized — waiting for user input...");
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    debugPrint("🧹 OTP fields disposed");
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _simulateOtpSend() {
    debugPrint("📤 Sending OTP to backend...");
    Future.delayed(const Duration(seconds: 2), () {
      debugPrint("✅ OTP sent successfully to user's number");
    });
  }

  void _simulateOtpVerification(String otp) {
    debugPrint("🔍 Verifying OTP: $otp");
    Future.delayed(const Duration(seconds: 1), () {
      if (otp == "123456") {
        debugPrint("✅ OTP verification successful");
      } else {
        debugPrint("❌ OTP verification failed");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    final boxHeight = screenHeight * 0.065;
    final fontSize = isSmallScreen ? 18.0 : 20.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(fieldCount, (index) {
        final isFocusedOrFilled =
            _focusNodes[index].hasFocus || _controllers[index].text.isNotEmpty;

        return Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: boxHeight,
            decoration: BoxDecoration(
              color: isFocusedOrFilled
                  ? const Color(0xffAFE1FE)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
              keyboardType: TextInputType.number,
              maxLength: 1,
              cursorColor: Colors.blue,
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (value.isNotEmpty && index < fieldCount - 1) {
                  FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                } else if (value.isEmpty && index > 0) {
                  FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                }

                setState(() {});
                final otp = _currentOtp;
                debugPrint("🔢 Current OTP input: $otp");

                // Notify parent
                widget.onChanged?.call(otp);

                // Simulate sending and verifying
                if (otp.length == fieldCount) {
                  _simulateOtpSend();
                  _simulateOtpVerification(otp);
                }
              },
            ),
          ),
        );
      }),
    );
  }
}
