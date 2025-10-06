import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/services/api_service.dart';
import 'package:geolocator/geolocator.dart';

class WorkerProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Worker Home State
  List<Map<String, dynamic>> _availableJobs = [];
  bool _isLoadingJobs = false;
  String? _searchLocation;
  String? _errorMessage;
  
  // Worker Registration State
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _workRadiusController = TextEditingController();
  
  File? _idCardImage;
  File? _policeClearanceFile;
  List<String> _selectedProfessions = [];
  bool _isLoadingRegistration = false;
  bool _isRegistered = false;
  
  // Worker Profile State
  String? _profileImageUrl;
  String? _workerName;
  double _workerRating = 0.0;
  
  // Apply for Job State
  bool _isApplyingForJob = false;
  String? _applyJobMessage;
  
  // Getters
  List<Map<String, dynamic>> get availableJobs => _availableJobs;
  bool get isLoadingJobs => _isLoadingJobs;
  String? get searchLocation => _searchLocation;
  String? get errorMessage => _errorMessage;
  
  // Registration Getters
  TextEditingController get usernameController => _usernameController;
  TextEditingController get ageController => _ageController;
  TextEditingController get experienceController => _experienceController;
  TextEditingController get workRadiusController => _workRadiusController;
  File? get idCardImage => _idCardImage;
  File? get policeClearanceFile => _policeClearanceFile;
  List<String> get selectedProfessions => _selectedProfessions;
  bool get isLoadingRegistration => _isLoadingRegistration;
  bool get isRegistered => _isRegistered;
  
  // Profile Getters
  String? get profileImageUrl => _profileImageUrl;
  String? get workerName => _workerName;
  double get workerRating => _workerRating;
  
  // Apply for Job Getters
  bool get isApplyingForJob => _isApplyingForJob;
  String? get applyJobMessage => _applyJobMessage;
  
  // Profession Options
  final List<Map<String, dynamic>> _professionOptions = [
    {"key": "1", "name": "Plumber"},
    {"key": "2", "name": "Electrician"},
    {"key": "3", "name": "Sweeper"},
    {"key": "4", "name": "Carpenter"},
    {"key": "5", "name": "Painter"},
    {"key": "99", "name": "Other"},
  ];
  
  List<Map<String, dynamic>> get professionOptions => _professionOptions;

  // Future<void> loadAvailableJobs() async {
  //   _isLoadingJobs = true;
  //   _errorMessage = null;
  //   notifyListeners();
  //
  //   try {
  //     final workerId = await ApiService.getUserId();
  //     final token = await ApiService.getJwtToken();
  //
  //     if (workerId != null && token != null) {
  //       // ✅ Step 1: Check and request location permissions
  //       LocationPermission permission = await Geolocator.checkPermission();
  //       if (permission == LocationPermission.denied) {
  //         permission = await Geolocator.requestPermission();
  //       }
  //
  //       if (permission == LocationPermission.deniedForever) {
  //         _errorMessage = "Location permission permanently denied.";
  //         _isLoadingJobs = false;
  //         notifyListeners();
  //         return;
  //       }
  //
  //       // ✅ Step 2: Get current location
  //       Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high,
  //       );
  //
  //       debugPrint("📍 Real Device Location: "
  //           "${position.latitude}, ${position.longitude}");
  //
  //       // ✅ Step 3: Send actual coordinates to API
  //       _availableJobs = await ApiService.testGetAvailableJobs(
  //         workerId: workerId,
  //         token: token,
  //         lat: position.latitude,
  //         lon: position.longitude,
  //       );
  //
  //       debugPrint("✅ Loaded ${_availableJobs.length} jobs from API");
  //     }
  //   } catch (e) {
  //     _errorMessage = 'Failed to load jobs: ${e.toString()}';
  //     debugPrint('❌ Error loading available jobs: $e');
  //   } finally {
  //     _isLoadingJobs = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> loadAvailableJobs() async {
    _isLoadingJobs = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ✅ Fixed workerId for testing
      final workerId = "f57e4f6e-a01d-4b5c-816c-49d20e1dd5dc";

      // ✅ Get stored token
      final token = await ApiService.getJwtToken();

      if (token != null) {
        // ✅ Fixed coordinates for testing (Lat=32, Lon=72)
        final double fixedLat = 32;
        final double fixedLon = 72;

        debugPrint("📍 Using Fixed Location: $fixedLat, $fixedLon");
        debugPrint("🔑 Using Fixed Worker ID: $workerId");

        // ✅ Send fixed coordinates to API
        _availableJobs = await ApiService.testGetAvailableJobs(
          workerId: workerId,
          token: token,
          lat: fixedLat,
          lon: fixedLon,
        );

        debugPrint("✅ Loaded ${_availableJobs.length} jobs from API");
        
        // Debug distance values
        for (int i = 0; i < _availableJobs.length; i++) {
          final job = _availableJobs[i];
          debugPrint("📍 Job $i - distanceKm: ${job["distanceKm"]}, distance: ${job["distance"]}");
        }
      } else {
        _errorMessage = "Missing authentication token.";
      }
    } catch (e) {
      _errorMessage = 'Failed to load jobs: ${e.toString()}';
      debugPrint('❌ Error loading available jobs: $e');
    } finally {
      _isLoadingJobs = false;
      notifyListeners();
    }
  }


  // Set Search Location
  void setSearchLocation(String? location) {
    _searchLocation = location;
    notifyListeners();
  }
  
  // Worker Registration Methods
  void setSelectedProfessions(List<String> professions) {
    _selectedProfessions = professions;
    notifyListeners();
  }
  
  void toggleProfession(String professionKey) {
    if (_selectedProfessions.contains(professionKey)) {
      _selectedProfessions.remove(professionKey);
    } else {
      _selectedProfessions.add(professionKey);
    }
    notifyListeners();
  }
  
  void setIdCardImage(File? image) {
    _idCardImage = image;
    notifyListeners();
  }
  
  void setPoliceClearanceFile(File? file) {
    _policeClearanceFile = file;
    notifyListeners();
  }
  
  // Check Registration Status
  Future<bool> checkRegistrationStatus() async {
    _isLoadingRegistration = true;
    notifyListeners();
    
    try {
      _isRegistered = await ApiService.checkWorkerRegistration();
      return _isRegistered;
    } catch (e) {
      debugPrint('Error checking registration status: $e');
      return false;
    } finally {
      _isLoadingRegistration = false;
      notifyListeners();
    }
  }
  
  // Register Worker
  Future<bool> registerWorker() async {
    if (_usernameController.text.trim().isEmpty ||
        _ageController.text.trim().isEmpty ||
        _experienceController.text.trim().isEmpty ||
        _workRadiusController.text.trim().isEmpty ||
        _selectedProfessions.isEmpty) {
      return false;
    }
    
    _isLoadingRegistration = true;
    notifyListeners();
    
    try {
      final userId = await ApiService.getUserId();
      if (userId == null) return false;
      
      final result = await ApiService.registerAsWorker(
        userId: userId,
        workRadius: _workRadiusController.text,
        extraDetails: _experienceController.text,
        professions: _selectedProfessions,
        idCardPath: _idCardImage?.path,
        policeClearanceFilePath: _policeClearanceFile?.path,
      );
      
      final status = result['statusCode'];
      if (status == 200 || status == 201) {
        _isRegistered = true;
        _clearRegistrationFields();
      }
      
      return status == 200 || status == 201;
    } catch (e) {
      debugPrint('Error registering worker: $e');
      return false;
    } finally {
      _isLoadingRegistration = false;
      notifyListeners();
    }
  }
  
  void _clearRegistrationFields() {
    _usernameController.clear();
    _ageController.clear();
    _experienceController.clear();
    _workRadiusController.clear();
    _selectedProfessions.clear();
    _idCardImage = null;
    _policeClearanceFile = null;
    notifyListeners();
  }
  
  // Load Worker Profile
  Future<void> loadWorkerProfile() async {
    try {
      final userId = await ApiService.getUserId();
      final token = await ApiService.getJwtToken();
      
      if (userId != null && token != null) {
        _profileImageUrl = await ApiService.getProfileImage(userId, token);
        // Load other profile data as needed
        _workerName = "John Doe"; // This should come from API
        _workerRating = 4.8; // This should come from API
      }
    } catch (e) {
      debugPrint('Error loading worker profile: $e');
    }
  }
  
  // Update Profile Image
  void updateProfileImage(String? imageUrl) {
    _profileImageUrl = imageUrl;
    notifyListeners();
  }
  
  // Filter Jobs by Location
  List<Map<String, dynamic>> getFilteredJobs() {
    if (_searchLocation == null || _searchLocation!.isEmpty) {
      return _availableJobs;
    }
    
    return _availableJobs.where((job) {
      final address = job['address']?.toString().toLowerCase() ?? '';
      return address.contains(_searchLocation!.toLowerCase());
    }).toList();
  }
  
  // Refresh Jobs
  Future<void> refreshJobs() async {
    await loadAvailableJobs();
  }
  
  // Apply for Job
  Future<Map<String, dynamic>> applyForJob({
    required String jobId,
  }) async {
    _isApplyingForJob = true;
    _applyJobMessage = null;
    notifyListeners();
    
    try {
      debugPrint('🎯 Starting apply for job with jobId: $jobId');
      
      final workerId = await ApiService.getUserId();
      debugPrint('👤 Worker ID: $workerId');
      
      if (workerId == null) {
        _applyJobMessage = 'Worker ID not found';
        debugPrint('❌ Worker ID is null');
        return {
          'success': false,
          'message': _applyJobMessage,
        };
      }

      debugPrint('📡 Calling ApiService.applyForJob with jobId: $jobId, workerId: $workerId');
      
      final result = await ApiService.applyForJob(
        jobId: jobId,
        workerId: workerId,
      );

      debugPrint('📊 API result: $result');

      if (result['success'] == true) {
        _applyJobMessage = 'Successfully applied for job!';
        debugPrint('✅ Successfully applied for job: $jobId');
      } else {
        _applyJobMessage = result['message'] ?? 'Failed to apply for job';
        debugPrint('❌ Failed to apply for job: ${result['message']}');
      }
      
      return result;
    } catch (e) {
      _applyJobMessage = 'Error applying for job: $e';
      debugPrint('💥 Exception applying for job: $e');
      debugPrint('💥 Exception type: ${e.runtimeType}');
      return {
        'success': false,
        'message': _applyJobMessage,
        'error': e.toString(),
      };
    } finally {
      _isApplyingForJob = false;
      notifyListeners();
    }
  }
  
  // Clear Apply Job Message
  void clearApplyJobMessage() {
    _applyJobMessage = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _experienceController.dispose();
    _workRadiusController.dispose();
    super.dispose();
  }
}
