import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/services/api_service.dart';

class CustomerProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Home State
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = false;
  String? _selectedCategory;
  
  // Post Job State
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  
  int? _selectedServiceKey;
  File? _selectedImage;
  File? _selectedVideo;
  String? _audioPath;
  bool _isLoading = false;
  bool _isLoadingVideo = false;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isRecordingVideo = false;
  Duration _recordingDuration = Duration.zero;
  Duration _videoRecordingDuration = Duration.zero;
  
  // Service Search State
  List<Map<String, dynamic>> _subServices = [];
  bool _isLoadingSubServices = false;
  String _searchQuery = '';
  
  // Getters
  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get selectedCategory => _selectedCategory;
  
  // Post Job Getters
  TextEditingController get titleController => _titleController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get addressController => _addressController;
  TextEditingController get feeController => _feeController;
  int? get selectedServiceKey => _selectedServiceKey;
  File? get selectedImage => _selectedImage;
  File? get selectedVideo => _selectedVideo;
  String? get audioPath => _audioPath;
  bool get isLoading => _isLoading;
  bool get isLoadingVideo => _isLoadingVideo;
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  bool get isRecordingVideo => _isRecordingVideo;
  Duration get recordingDuration => _recordingDuration;
  Duration get videoRecordingDuration => _videoRecordingDuration;
  
  // Service Search Getters
  List<Map<String, dynamic>> get subServices => _subServices;
  bool get isLoadingSubServices => _isLoadingSubServices;
  String get searchQuery => _searchQuery;
  
  // Service Options
  final Map<String, int> _allServiceOptions = {
    'Plumber': 1,
    'Electrician': 2,
    'Sweeper': 3,
    'Carpenter': 4,
    'Painter': 5,
    'HVAC': 6,
    'Appliance Repair': 7,
    'Landscaping': 8,
    'Security': 9,
    'Maintenance': 10,
    'IT Support': 11,
    'Other': 99,
  };
  
  Map<String, int> get allServiceOptions => _allServiceOptions;
  
  // Load Categories
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    notifyListeners();
    
    try {
      final categories = await ApiService.fetchCategories();
      _categories = categories.map((category) => {
        'id': category.id,
        'name': category.title,
        'imageUrl': category.imageUrl,
      }).toList();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }
  
  // Set Selected Category
  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  // Post Job Methods
  void setSelectedServiceKey(int? serviceKey) {
    _selectedServiceKey = serviceKey;
    notifyListeners();
  }
  
  void setSelectedImage(File? image) {
    _selectedImage = image;
    _selectedVideo = null; // Clear video if image is selected
    notifyListeners();
  }
  
  void setSelectedVideo(File? video) {
    _selectedVideo = video;
    _selectedImage = null; // Clear image if video is selected
    notifyListeners();
  }
  
  void setAudioPath(String? path) {
    _audioPath = path;
    notifyListeners();
  }
  
  void setRecording(bool recording) {
    _isRecording = recording;
    if (recording) {
      _recordingDuration = Duration.zero;
    }
    notifyListeners();
  }
  
  void setPlaying(bool playing) {
    _isPlaying = playing;
    notifyListeners();
  }
  
  void setRecordingVideo(bool recording) {
    _isRecordingVideo = recording;
    if (recording) {
      _videoRecordingDuration = Duration.zero;
    }
    notifyListeners();
  }
  
  void updateRecordingDuration(Duration duration) {
    _recordingDuration = duration;
    notifyListeners();
  }
  
  void updateVideoRecordingDuration(Duration duration) {
    _videoRecordingDuration = duration;
    notifyListeners();
  }
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void setLoadingVideo(bool loading) {
    _isLoadingVideo = loading;
    notifyListeners();
  }
  
  void clearMedia() {
    _selectedImage = null;
    _selectedVideo = null;
    notifyListeners();
  }
  
  void deleteAudio() {
    _audioPath = null;
    _isRecording = false;
    _isPlaying = false;
    _recordingDuration = Duration.zero;
    notifyListeners();
  }
  
  // Submit Job
  Future<bool> submitJob() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _selectedServiceKey == null) {
      return false;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = await ApiService.getJwtToken();
      if (token == null) return false;
      
      final feeText = _feeController.text.trim();
      final feeRange = _parseFeeRange(feeText);
      if (feeRange == null) return false;
      
      final result = await ApiService.createJob(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        token: token,
        minFee: feeRange['min']!,
        maxFee: feeRange['max']!,
        serviceKey: _selectedServiceKey!,
        imagePath: _selectedImage?.path,
        videoPath: _selectedVideo?.path,
        audioPath: _audioPath,
        latitude: 0.0, // Will be set by GPS
        longitude: 0.0, // Will be set by GPS
      );
      
      if (result['success'] == true) {
        clearAllFields();
      }
      
      return result['success'] ?? false;
    } catch (e) {
      debugPrint('Error submitting job: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearAllFields() {
    _titleController.clear();
    _descriptionController.clear();
    _addressController.clear();
    _feeController.clear();
    _selectedServiceKey = null;
    _selectedImage = null;
    _selectedVideo = null;
    _audioPath = null;
    _isRecording = false;
    _isPlaying = false;
    _recordingDuration = Duration.zero;
    _videoRecordingDuration = Duration.zero;
    notifyListeners();
  }
  
  // Service Search Methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  Future<void> loadSubServices(String categoryKey) async {
    _isLoadingSubServices = true;
    notifyListeners();
    
    try {
      final subServices = await ApiService.fetchAllSubCategories(categoryKey);
      _subServices = subServices.map((service) => {
        'id': service.id,
        'name': service.name,
        'imageUrl': service.imageUrl,
      }).toList();
    } catch (e) {
      debugPrint('Error loading sub services: $e');
    } finally {
      _isLoadingSubServices = false;
      notifyListeners();
    }
  }
  
  List<Map<String, dynamic>> getFilteredSubServices() {
    if (_searchQuery.isEmpty) return _subServices;
    
    return _subServices.where((service) {
      final name = service['name']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }
  
  // Helper Methods
  Map<String, int>? _parseFeeRange(String feeText) {
    final cleanText = feeText.trim().toLowerCase();
    
    if (cleanText.contains('-')) {
      final parts = cleanText.split('-');
      if (parts.length == 2) {
        final minStr = parts[0].trim();
        final maxStr = parts[1].trim();
        
        final minFee = int.tryParse(minStr);
        final maxFee = int.tryParse(maxStr);
        
        if (minFee != null && maxFee != null) {
          return {'min': minFee, 'max': maxFee};
        }
      }
    }
    
    final singleFee = int.tryParse(cleanText);
    if (singleFee != null) {
      return {'min': singleFee, 'max': singleFee};
    }
    
    return null;
  }
  
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _feeController.dispose();
    super.dispose();
  }
}
