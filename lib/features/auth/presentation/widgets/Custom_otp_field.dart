import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class CustomOtpFields extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const CustomOtpFields({super.key, this.onChanged});

  @override
  State<CustomOtpFields> createState() => _CustomOtpFieldsState();
}

class _CustomOtpFieldsState extends State<CustomOtpFields> with CodeAutoFill {
  final int fieldCount = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(fieldCount, (_) => TextEditingController());
    _focusNodes = List.generate(fieldCount, (_) => FocusNode());
    listenForCode();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    cancel();
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();


  @override
  void codeUpdated() {
    final receivedCode = code!;
    if (receivedCode.length == fieldCount) {
      _fillOtpFields(receivedCode);
    }
  }

  void _fillOtpFields(String code) {
    for (int i = 0; i < fieldCount && i < code.length; i++) {
      _controllers[i].text = code[i];
    }
    setState(() {});
    widget.onChanged?.call(_currentOtp);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(fieldCount, (index) {
        final isFocusedOrFilled =
            _focusNodes[index].hasFocus || _controllers[index].text.isNotEmpty;
        return Container(
          width: 51,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isFocusedOrFilled ? const Color(0xffAFE1FE) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
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

              
              widget.onChanged?.call(_currentOtp);
            },
          ),
        );
      }),
    );
  }
}
