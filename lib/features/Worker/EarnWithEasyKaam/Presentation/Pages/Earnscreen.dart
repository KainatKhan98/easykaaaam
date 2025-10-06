import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../../../../core/services/api_service.dart';


class EarnScreen extends StatefulWidget {
  const EarnScreen({super.key});

  @override
  State<EarnScreen> createState() => _EarnScreenState();
}

class _EarnScreenState extends State<EarnScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _workRadiusController = TextEditingController();

  // Files
  File? _idCardImage;
  File? _policeClearanceFile;
  final ImagePicker _picker = ImagePicker();

  // Professions with correct numeric mapping
  final List<Map<String, dynamic>> _professionOptions = [
    {"key": "1", "name": "Plumber"},
    {"key": "2", "name": "Electrician"},
    {"key": "3", "name": "Sweeper"},
    {"key": "4", "name": "Carpenter"},
    {"key": "5", "name": "Painter"},
    {"key": "99", "name": "Other"},
  ];
  List<String> _selectedProfessions = [];

  Future<void> _pickIdCardImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _idCardImage = File(pickedFile.path));
      final fileSize = await _idCardImage!.length();
      debugPrint('📄 ID Card file size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
    }
  }

  Future<void> _pickPoliceClearanceFile() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _policeClearanceFile = File(pickedFile.path));
      final fileSize = await _policeClearanceFile!.length();
      debugPrint('📄 Police Clearance file size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
    }
  }

  Future<void> _checkRegistrationStatus() async {
    try {
      debugPrint("🔍 Checking if user is already registered as worker...");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ),
      );

      final isRegistered = await ApiService.checkWorkerRegistration();

      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        if (isRegistered) {
          _showRegistrationStatusDialog(
            title: "Already Registered!",
            message: "You are already registered as a worker. Redirecting to your dashboard...",
            isSuccess: true,
            onConfirm: () {
              Navigator.of(context).pushReplacementNamed('/worker-home');
            },
          );
        } else {
          _showRegistrationStatusDialog(
            title: "Not Registered",
            message: "You are not registered as a worker yet. Please fill out the registration form above to get started!",
            isSuccess: false,
            onConfirm: () {
            },
          );
        }
      }
    } catch (e) {

      if (mounted) Navigator.of(context).pop();

      debugPrint('Error checking registration status: $e');
      if (mounted) {
        _showRegistrationStatusDialog(
          title: "Error",
          message: "Could not check your registration status. Please try again or contact support.",
          isSuccess: false,
          onConfirm: () {
          },
        );
      }
    }
  }

  void _showRegistrationStatusDialog({
    required String title,
    required String message,
    required bool isSuccess,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info,
              color: isSuccess ? Colors.green : Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.blue,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(
              isSuccess ? "Go to Dashboard" : "Got it",
              style: TextStyle(
                color: isSuccess ? Colors.green : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registerWorker() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final userId = await ApiService.getUserId();

    if (userId == null || !_formKey.currentState!.validate() || _selectedProfessions.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields and select at least one profession.")),
      );
      return;
    }

    try {
      final result = await ApiService.registerAsWorker(
        userId: userId,
        workRadius: _workRadiusController.text,
        extraDetails: _experienceController.text,
        professions: _selectedProfessions,
        idCardPath: _idCardImage?.path,
        policeClearanceFilePath: _policeClearanceFile?.path,
      );

      final status = result['statusCode'];
      final body = result['body'] ?? result['error'] ?? 'Unknown error';
      final details = result['details'];

      debugPrint("📥 Registration result: Status=$status, Body=$body, Details=$details");

      if (status == 200 || status == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Worker registered successfully! Redirecting to home..."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/worker-home');
        }
      } else if (status == 400 && body.toString().contains('Already Registered')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You are already registered as a worker! Redirecting to home..."),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/worker-home');
        }
      } else if (status == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Authentication failed. Please login again."),
            backgroundColor: Colors.red,
          ),
        );
      } else if (status == 500) {
        String errorMessage = body.toString();
        final attempts = result['attempts'] ?? 1;

        if (errorMessage.contains('Server connection was reset')) {
          errorMessage = "Server connection was reset. This might be due to server overload. Please try again in a few moments.";
        } else if (errorMessage.contains('Request timed out')) {
          errorMessage = "Request timed out. The server might be busy. Please try again.";
        } else if (errorMessage.contains('Network connection failed')) {
          errorMessage = "Network connection failed. Please check your internet connection and try again.";
        }

        if (attempts > 1) {
          errorMessage += "\n\nTried $attempts times before failing.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                _registerWorker();
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration failed: $body (Status: $status)"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('Error registering worker: $e');
      debugPrint('$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8DD4FD), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8DD4FD), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildFileUpload({
    required String label,
    required File? file,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: DottedBorder(
            color: const Color(0xff8DD4FD),
            strokeWidth: 2,
            dashPattern: const [6, 3],
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: file == null
                  ? const Center(
                child: Icon(Icons.image_outlined, size: 50, color: Color(0xff8DD4FD)),
              )
                  : Image.file(file, fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Professions"),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF8DD4FD), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _professionOptions.map((profession) {
              final isSelected = _selectedProfessions.contains(profession["key"]);
              return CheckboxListTile(
                title: Text(profession["name"]),
                value: isSelected,
                activeColor: const Color(0xFF8DD4FD),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedProfessions.add(profession["key"]);
                    } else {
                      _selectedProfessions.remove(profession["key"]);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _experienceController.dispose();
    _workRadiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8DD4FD), Color(0xFF547F97)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 40),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -3)),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Earn with EasyKaam",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                              Icon(Icons.more_vert, size: 28, color: Color(0xff25B0F0)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _buildTextField(
                            label: "Enter Your Name",
                            controller: _usernameController,
                            validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: "Enter Your Age",
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? 'Enter your age' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: "Experience",
                            controller: _experienceController,
                            validator: (v) => v == null || v.isEmpty ? 'Enter your experience' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: "Work Radius (in km)",
                            controller: _workRadiusController,
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? 'Enter work radius' : null,
                          ),
                          const SizedBox(height: 16),

                          _buildProfessionDropdown(),

                          const SizedBox(height: 20),

                          _buildFileUpload(label: "Upload ID Card", file: _idCardImage, onTap: _pickIdCardImage),
                          const SizedBox(height: 16),
                          _buildFileUpload(
                              label: "Upload Police Clearance",
                              file: _policeClearanceFile,
                              onTap: _pickPoliceClearanceFile),

                          const SizedBox(height: 24),
                          Center(
                            child: SizedBox(
                              width: 250,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _registerWorker,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff8DD4FD),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text(
                                  "Register",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}