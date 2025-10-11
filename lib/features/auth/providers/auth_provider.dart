import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Auth State
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _userId;
  String? _userPhone;
  String? _userRole;
  String? _jwtToken;
  String? _refreshToken;
  String? _profileImageUrl;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userPhone => _userPhone;
  String? get userRole => _userRole;
  String? get jwtToken => _jwtToken;
  String? get refreshToken => _refreshToken;
  String? get profileImageUrl => _profileImageUrl;
  
  // Initialize auth state
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _userId = await ApiService.getUserId();
      _userPhone = await ApiService.getUserPhone();
      final roleId = await ApiService.getUserRole();
      _userRole = roleId?.toString();
      _jwtToken = await ApiService.getJwtToken();
      _isAuthenticated = await ApiService.isAuthenticated();
      
      if (_isAuthenticated && _userId != null) {
        _profileImageUrl = await ApiService.getProfileImage(_userId!, _jwtToken!);
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Send OTP
  Future<bool> sendOtp(String name, String phoneNumber) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final result = await ApiService.sendOtp(name, phoneNumber);
      return result['success'] ?? false;
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Verify OTP
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final result = await ApiService.verifyOtp(
        phoneNo: phoneNumber,
        otpCode: otp,
      );
      if (result['success'] == true) {
        _isAuthenticated = true;
        _userId = result['userId'];
        _userPhone = phoneNumber;
        _jwtToken = result['token'];
        _refreshToken = result['refreshToken'];
        
        await ApiService.storeUserId(_userId!);
        await ApiService.storeUserPhone(_userPhone!);
        // Note: _storeJwtToken and _storeRefreshToken are private methods
        // They are called internally by the verifyOtp method
      }
      return result['success'] ?? false;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await ApiService.clearAuthData();
      _isAuthenticated = false;
      _userId = null;
      _userPhone = null;
      _userRole = null;
      _jwtToken = null;
      _refreshToken = null;
      _profileImageUrl = null;
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Force reinitialize auth state (useful for hot restart)
  Future<void> forceReinitialize() async {
    // Reset state without notifying listeners first
    _isLoading = false;
    _isAuthenticated = false;
    _userId = null;
    _userPhone = null;
    _userRole = null;
    _jwtToken = null;
    _refreshToken = null;
    _profileImageUrl = null;
    
    // Then initialize
    await initializeAuth();
  }
  
  // Update profile image
  Future<void> updateProfileImage(String imageUrl) async {
    _profileImageUrl = imageUrl;
    notifyListeners();
  }
  
  // Refresh token
  // Future<bool> refreshToken() async {
  //   try {
  //     if (_refreshToken != null && _userPhone != null && _userRole != null) {
  //       final result = await ApiService.refreshJwtToken(
  //         phoneNo: _userPhone!,
  //         roleId: int.parse(_userRole!),
  //       );
  //       if (result['success'] == true) {
  //         _jwtToken = result['token'];
  //         await ApiService._storeJwtToken(_jwtToken!);
  //         return true;
  //       }
  //     }
  //     return false;
  //   } catch (e) {
  //     debugPrint('Error refreshing token: $e');
  //     return false;
  //   }
  // }
}
