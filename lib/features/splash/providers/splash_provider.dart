import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class SplashProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Splash State
  bool _isLoading = true;
  bool _isInitialized = false;
  String? _errorMessage;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  
  // Initialize App
  Future<void> initializeApp() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Wait a bit for splash effect
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check authentication status
      final isAuthenticated = await ApiService.isAuthenticated();
      
      // Load any necessary initial data
      await _loadInitialData();
      
      _isInitialized = true;
    } catch (e) {
      _errorMessage = 'Failed to initialize app: $e';
      debugPrint('Splash initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load initial data
  Future<void> _loadInitialData() async {
    try {
      // Load any app-wide initial data here
      // For example: user preferences, cached data, etc.
      await Future.delayed(const Duration(seconds: 2)); // Simulate loading
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
  }
  
  // Retry initialization
  Future<void> retryInitialization() async {
    await initializeApp();
  }
  
  // Reset splash state (without notifying listeners)
  void _resetSplashState() {
    _isLoading = true;
    _isInitialized = false;
    _errorMessage = null;
  }
  
  // Reset splash state (public method)
  void resetSplashState() {
    _resetSplashState();
    notifyListeners();
  }
  
  // Force reinitialize app (useful for hot restart)
  Future<void> forceReinitialize() async {
    _resetSplashState(); // Don't notify listeners during reset
    await initializeApp();
  }
}
