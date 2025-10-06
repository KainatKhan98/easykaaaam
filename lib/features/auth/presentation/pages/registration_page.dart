
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import 'otp_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool isLoading = false;

  Future<void> sendOtp() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _showSnackBar("Please enter name and phone number");
      return;
    }

    // Always normalize before sending to backend
    final backendPhone = normalizePhoneForBackend(phone);

    if (!_isValidPhoneNumber(phone)) {
      _showSnackBar("Invalid phone number");
      return;
    }

    debugPrint("📨 Sending to backend: $backendPhone");

    setState(() => isLoading = true);

    try {
      final result = await ApiService.sendOtp(name, backendPhone);

      if (result['success'] && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OtpScreen(phoneNo: backendPhone)),
        );
      } else {
        _showSnackBar("Failed to send OTP: ${result['message']}");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }


  String _formatPhoneNumber(String phone) {
    // Remove spaces, dashes, etc.
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // If user typed 3xx..., convert to 03xx...
    if (cleanPhone.startsWith('3') && cleanPhone.length == 10) {
      return '0$cleanPhone';
    }

    // If already starts with 03 and has 11 digits, return as is
    if (cleanPhone.startsWith('03') && cleanPhone.length == 11) {
      return cleanPhone;
    }

    // If starts with 92xxxxxxxxxx, convert to 03xxxxxxxxx
    if (cleanPhone.startsWith('92') && cleanPhone.length == 12) {
      return '0${cleanPhone.substring(2)}';
    }

    return cleanPhone;
  }

  String normalizePhoneForBackend(String phone) {
    // Remove all non-digits
    var cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // If it starts with "3", add leading 0
    if (cleanPhone.length == 10 && cleanPhone.startsWith('3')) {
      cleanPhone = '0$cleanPhone';
    }

    return cleanPhone; // always 11 digits, starting with 0
  }

  bool _isValidPhoneNumber(String phone) {
    // Remove everything except digits
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Allow:
    // - 11 digits starting with 03
    // - 10 digits starting with 3 (user skipped the 0)
    if (RegExp(r'^03\d{9}$').hasMatch(cleanPhone)) return true;
    if (RegExp(r'^3\d{9}$').hasMatch(cleanPhone)) return true;

    return false;
  }



  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8DD4FD), Color(0xFF547F97)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildLogo() => Center(
    child: Image.asset(
      "assets/logo/logo.png",
      fit: BoxFit.contain,
      height: 145,
      width: 259,
    ),
  );

  Widget _buildContentContainer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(60),
          topRight: Radius.circular(60),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeText(),
            _buildNameField(),
            _buildPhoneField(),
            const SizedBox(height: 30),
            Center(
              child: AuthButton(
                text: isLoading ? "Sending..." : "Send OTP",
                color: const Color(AppConstants.primaryBlue),
                onPressed: isLoading ? null : sendOtp,
              ),
            ),
            const SizedBox(height: 20),
            _buildDividerRow(),
            const SizedBox(height: 12),
            _buildWhatsappRegistration(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText() => const Padding(
    padding: EdgeInsets.only(top: 60, bottom: 20, left: 40, right: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Create your account",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: Color(0xFF808080),
          ),
        ),
      ],
    ),
  );

  Widget _buildNameField() => Padding(
    padding: const EdgeInsets.only(top: 20, left: 35, right: 20),
    child: AuthTextField(
      controller: _nameController,
      hintText: "Full Name",
      keyboardType: TextInputType.name,
    ),
  );

  Widget _buildPhoneField() => Padding(
    padding: const EdgeInsets.only(top: 20, left: 35, right: 20),
    child: SizedBox(
      width: 340,
      height: 57,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF747474)),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          children: [
            _buildCountryCode(),
            SizedBox(
              width: 5,
            ),
            _buildPhoneInput(),
          ],
        ),
      ),
    ),
  );

  Widget _buildCountryCode() => Container(
    width: 80,
    height: 57,
    decoration: const BoxDecoration(
      color: Color(0xFFF5F5F5),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          "+92",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        Icon(Icons.arrow_drop_down, size: 20, color: Colors.black54),
      ],
    ),
  );

  Widget _buildPhoneInput() => Expanded(
    child: Container(
      height: 57,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        textAlign: TextAlign.left,
        onChanged: (value) {
          final formatted = _formatPhoneNumber(value);
          if (formatted != value) {
            _phoneController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        },

        decoration: const InputDecoration(
          hintText: "3xx-xxxxxxx",
          hintStyle: TextStyle(fontFamily: 'Inter'),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        ),
      ),
    ),
  );

  Widget _buildDividerRow() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      SizedBox(width: 120, child: Divider(color: Colors.grey, thickness: 1)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          "or",
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.black54),
        ),
      ),
      SizedBox(width: 120, child: Divider(color: Colors.grey, thickness: 1)),
    ],
  );

  Widget _buildWhatsappRegistration() => Center(
    child: TextButton(
      onPressed: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            "Via WhatsApp",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: Colors.grey,
              decoration: TextDecoration.underline,
            ),
          ),
          SizedBox(width: 8),
          FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 20),
        ],
      ),
    ),
  );
} 