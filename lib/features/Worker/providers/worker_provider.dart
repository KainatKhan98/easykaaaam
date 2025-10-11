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
  
  // Pagination State
  int _currentPage = 1;
  int _pageSize = 10;
  bool _hasMoreJobs = true;
  bool _isLoadingMore = false;
  int _totalJobs = 0; // Track total jobs from API
  
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
  String? _lastAppliedJobId;
  
  // Job Applicants State
  List<Map<String, dynamic>> _jobApplicants = [];
  bool _isLoadingApplicants = false;
  String? _applicantsErrorMessage;
  
  // Getters
  List<Map<String, dynamic>> get availableJobs => _availableJobs;
  bool get isLoadingJobs => _isLoadingJobs;
  String? get searchLocation => _searchLocation;
  String? get errorMessage => _errorMessage;
  
  // Pagination Getters
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMoreJobs => _hasMoreJobs;
  bool get isLoadingMore => _isLoadingMore;
  int get totalPages => _totalJobs > 0 ? (_totalJobs / _pageSize).ceil() : (_availableJobs.length / _pageSize).ceil();
  int get totalItems => _totalJobs > 0 ? _totalJobs : _availableJobs.length;
  
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
  String? get lastAppliedJobId => _lastAppliedJobId;
  
  // Job Applicants Getters
  List<Map<String, dynamic>> get jobApplicants => _jobApplicants;
  bool get isLoadingApplicants => _isLoadingApplicants;
  String? get applicantsErrorMessage => _applicantsErrorMessage;
  
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

  Future<void> loadAvailableJobs({bool resetPagination = true}) async {
    if (resetPagination) {
      _currentPage = 1;
      _availableJobs.clear();
      _hasMoreJobs = true;
      _totalJobs = 0;
    }
    
    _isLoadingJobs = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ✅ Get actual workerId from storage
      final workerId = await ApiService.getWorkerId();
      
      if (workerId == null) {
        _errorMessage = "Worker ID not found. Please register as a worker first.";
        _isLoadingJobs = false;
        notifyListeners();
        return;
      }

      // ✅ Get stored token
      final token = await ApiService.getJwtToken();

      if (token != null) {
        // ✅ Fixed coordinates for testing (Lat=32, Lon=72)
        final double fixedLat = 32;
        final double fixedLon = 72;

        debugPrint("📍 Using Fixed Location: $fixedLat, $fixedLon");
        debugPrint("🔑 Using Actual Worker ID: $workerId");
        debugPrint("📄 Loading page $_currentPage with $_pageSize items per page");

        // ✅ Send fixed coordinates to API with pagination
        final newJobs = await ApiService.testGetAvailableJobs(
          workerId: workerId,
          token: token,
          lat: fixedLat,
          lon: fixedLon,
          pageNumber: _currentPage,
          pageSize: _pageSize,
        );

        // For pagination, we replace the current jobs (don't append)
        _availableJobs = newJobs;

        // Check if there are more jobs to load
        _hasMoreJobs = newJobs.length == _pageSize;
        
        // Estimate total jobs based on current page and items
        if (_hasMoreJobs) {
          _totalJobs = (_currentPage * _pageSize) + 1; // At least one more page
        } else {
          _totalJobs = (_currentPage - 1) * _pageSize + newJobs.length;
        }

        debugPrint("✅ Loaded ${newJobs.length} jobs from API (Page $_currentPage)");
        debugPrint("📊 Total jobs: ${_availableJobs.length}, Has more: $_hasMoreJobs, Estimated total: $_totalJobs");
        
        // Debug distance values
        for (int i = 0; i < newJobs.length; i++) {
          final job = newJobs[i];
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
        
        // Check if workerId was returned and stored
        final workerId = result['workerId'];
        if (workerId != null) {
          debugPrint('✅ Worker registration successful with ID: $workerId');
        } else {
          debugPrint('⚠️ Worker registration successful but no workerId returned');
        }
        
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
  
  // Load More Jobs (for pagination)
  Future<void> loadMoreJobs() async {
    if (!_hasMoreJobs || _isLoadingMore || _isLoadingJobs) {
      return;
    }

    _isLoadingMore = true;
    _currentPage++;
    notifyListeners();

    try {
      // ✅ Get actual workerId from storage
      final workerId = await ApiService.getWorkerId();
      
      if (workerId == null) {
        debugPrint("❌ Worker ID not found for loading more jobs");
        _isLoadingMore = false;
        notifyListeners();
        return;
      }

      // ✅ Get stored token
      final token = await ApiService.getJwtToken();

      if (token != null) {
        // ✅ Fixed coordinates for testing (Lat=32, Lon=72)
        final double fixedLat = 32;
        final double fixedLon = 72;

        debugPrint("📄 Loading more jobs - Page $_currentPage with workerId: $workerId");

        // ✅ Send fixed coordinates to API with pagination
        final newJobs = await ApiService.testGetAvailableJobs(
          workerId: workerId,
          token: token,
          lat: fixedLat,
          lon: fixedLon,
          pageNumber: _currentPage,
          pageSize: _pageSize,
        );

        _availableJobs.addAll(newJobs);

        // Check if there are more jobs to load
        _hasMoreJobs = newJobs.length == _pageSize;

        debugPrint("✅ Loaded ${newJobs.length} more jobs (Page $_currentPage)");
        debugPrint("📊 Total jobs: ${_availableJobs.length}, Has more: $_hasMoreJobs");
      }
    } catch (e) {
      debugPrint('❌ Error loading more jobs: $e');
      // Revert page number on error
      _currentPage--;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Navigate to specific page
  Future<void> goToPage(int page) async {
    if (page < 1 || page == _currentPage || _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      // ✅ Get actual workerId from storage
      final workerId = await ApiService.getWorkerId();
      
      if (workerId == null) {
        debugPrint("❌ Worker ID not found for page navigation");
        _isLoadingMore = false;
        notifyListeners();
        return;
      }

      // ✅ Get stored token
      final token = await ApiService.getJwtToken();

      if (token != null) {
        // ✅ Fixed coordinates for testing (Lat=32, Lon=72)
        final double fixedLat = 32;
        final double fixedLon = 72;

        debugPrint("📄 Navigating to page $page with workerId: $workerId");

        // ✅ Send fixed coordinates to API with pagination
        final newJobs = await ApiService.testGetAvailableJobs(
          workerId: workerId,
          token: token,
          lat: fixedLat,
          lon: fixedLon,
          pageNumber: page,
          pageSize: _pageSize,
        );

        // Update current page and jobs
        _currentPage = page;
        _availableJobs = newJobs;

        // Check if there are more jobs to load
        _hasMoreJobs = newJobs.length == _pageSize;
        
        // Update total jobs estimate
        if (_hasMoreJobs) {
          _totalJobs = (_currentPage * _pageSize) + 1;
        } else {
          _totalJobs = (_currentPage - 1) * _pageSize + newJobs.length;
        }

        debugPrint("✅ Loaded page $page with ${newJobs.length} jobs");
        debugPrint("📊 Total jobs: ${_availableJobs.length}, Has more: $_hasMoreJobs, Estimated total: $_totalJobs");
      }
    } catch (e) {
      debugPrint('❌ Error navigating to page $page: $e');
      // Revert page number on error
      _currentPage = 1;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Go to previous page
  Future<void> goToPreviousPage() async {
    if (_currentPage > 1) {
      await goToPage(_currentPage - 1);
    }
  }

  // Go to next page
  Future<void> goToNextPage() async {
    if (_currentPage < totalPages) {
      await goToPage(_currentPage + 1);
    }
  }

  // Refresh Jobs
  Future<void> refreshJobs() async {
    await loadAvailableJobs(resetPagination: true);
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
      
      // Get actual workerId from storage
      final workerId = await ApiService.getWorkerId();
      
      if (workerId == null) {
        _applyJobMessage = 'Worker ID not found. Please register as a worker first.';
        debugPrint('❌ Worker ID not found for apply for job');
        return {
          'success': false,
          'message': _applyJobMessage,
          'error': 'Worker ID not found',
        };
      }
      
      debugPrint('👤 Using actual Worker ID for apply for job: $workerId');

      debugPrint('📡 Calling ApiService.applyForJob with jobId: $jobId, workerId: $workerId');
      
      final result = await ApiService.applyForJob(
        jobId: jobId,
        workerId: workerId,
      );

      debugPrint('📊 API result: $result');

      if (result['success'] == true) {
        _applyJobMessage = 'Successfully applied for job!';
        _lastAppliedJobId = result['jobId'] ?? jobId; // Store jobId from response or use parameter
        debugPrint('✅ Successfully applied for job: $jobId');
        debugPrint('📝 Stored jobId: $_lastAppliedJobId');
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
  
  // Get Job Applicants using stored jobId
  Future<void> getJobApplicantsForLastAppliedJob({int pageNumber = 1, int pageSize = 15}) async {
    if (_lastAppliedJobId == null) {
      _applicantsErrorMessage = 'No job ID available. Please apply for a job first.';
      notifyListeners();
      return;
    }
    
    _isLoadingApplicants = true;
    _applicantsErrorMessage = null;
    notifyListeners();
    
    try {
      debugPrint('🔍 Getting job applicants for stored jobId: $_lastAppliedJobId');
      
      final result = await ApiService.getAllJobApplicants(
        jobId: _lastAppliedJobId!,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      
      if (result['success'] == true) {
        _jobApplicants = List<Map<String, dynamic>>.from(result['data'] ?? []);
        debugPrint('✅ Loaded ${_jobApplicants.length} job applicants for job: $_lastAppliedJobId');
      } else {
        _applicantsErrorMessage = result['message'] ?? 'Failed to load applicants';
        debugPrint('❌ Error loading job applicants: ${_applicantsErrorMessage}');
      }
    } catch (e) {
      _applicantsErrorMessage = 'Error loading applicants: ${e.toString()}';
      debugPrint('💥 Exception loading job applicants: $e');
    } finally {
      _isLoadingApplicants = false;
      notifyListeners();
    }
  }
  
  // Get Job Applicants using specific jobId
  Future<void> getJobApplicants(String jobId, {int pageNumber = 1, int pageSize = 15}) async {
    _isLoadingApplicants = true;
    _applicantsErrorMessage = null;
    notifyListeners();
    
    try {
      debugPrint('🔍 Getting job applicants for jobId: $jobId');
      
      final result = await ApiService.getAllJobApplicants(
        jobId: jobId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      
      if (result['success'] == true) {
        _jobApplicants = List<Map<String, dynamic>>.from(result['data'] ?? []);
        debugPrint('✅ Loaded ${_jobApplicants.length} job applicants for job: $jobId');
      } else {
        _applicantsErrorMessage = result['message'] ?? 'Failed to load applicants';
        debugPrint('❌ Error loading job applicants: ${_applicantsErrorMessage}');
      }
    } catch (e) {
      _applicantsErrorMessage = 'Error loading applicants: ${e.toString()}';
      debugPrint('💥 Exception loading job applicants: $e');
    } finally {
      _isLoadingApplicants = false;
      notifyListeners();
    }
  }
  
  // Clear Job Applicants
  void clearJobApplicants() {
    _jobApplicants.clear();
    _applicantsErrorMessage = null;
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
