import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class SupportProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Support State
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;
  
  // Form State
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  
  // Form Getters
  TextEditingController get nameController => _nameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get subjectController => _subjectController;
  TextEditingController get messageController => _messageController;
  
  // Submit Support Form
  Future<bool> submitSupportForm() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _subjectController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      _errorMessage = 'Please fill in all fields';
      notifyListeners();
      return false;
    }
    
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    
    try {
      // Here you would typically call an API to submit the support form
      // For now, we'll simulate a successful submission
      await Future.delayed(const Duration(seconds: 2));
      
      _successMessage = 'Your support request has been submitted successfully!';
      _clearForm();
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit support request: $e';
      debugPrint('Error submitting support form: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
  
  // Clear form
  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _messageController.clear();
  }
  
  // Clear messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
  
  // Validate email
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  // Validate form
  bool isFormValid() {
    return _nameController.text.trim().isNotEmpty &&
           _emailController.text.trim().isNotEmpty &&
           _subjectController.text.trim().isNotEmpty &&
           _messageController.text.trim().isNotEmpty &&
           isValidEmail(_emailController.text.trim());
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

