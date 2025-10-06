import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:video_compress/video_compress.dart';
import '../../../../../core/services/api_service.dart';
import '../../../providers/customer_provider.dart';
import '../../../service_search/presentation/pages/service_search_page.dart';
import '../widgets/chat.dart';





class PostJobScreen extends StatefulWidget {
  final int? preselectedServiceKey;
  
  const PostJobScreen({super.key, this.preselectedServiceKey});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    
    // Initialize provider state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      if (widget.preselectedServiceKey != null) {
        customerProvider.setSelectedServiceKey(widget.preselectedServiceKey);
      }
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _clearMedia() {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    customerProvider.clearMedia();
  }

  void _deleteAudio() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Audio'),
          content: const Text('Are you sure you want to delete the recorded audio?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
                customerProvider.deleteAudio();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
        customerProvider.setSelectedImage(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 15),
      );

      if (video != null) {
        final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
        customerProvider.setLoadingVideo(true);
        
        try {
          final compressedVideo = await VideoCompress.compressVideo(
            video.path,
            quality: VideoQuality.MediumQuality,
            deleteOrigin: false,
          );

          if (compressedVideo != null && compressedVideo.file != null) {
            customerProvider.setSelectedVideo(compressedVideo.file!);
          }
        } finally {
          customerProvider.setLoadingVideo(false);
        }
      }

    } catch (e) {
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      customerProvider.setLoadingVideo(false);
      _showErrorSnackBar('Error picking video: $e');
    }
  }


  Future<void> _recordInstantVideo() async {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    customerProvider.setRecordingVideo(true);

    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 15),
      );

      if (video != null) {
        customerProvider.setLoadingVideo(true);
        
        try {
          final compressedVideo = await VideoCompress.compressVideo(
            video.path,
            quality: VideoQuality.MediumQuality,
            deleteOrigin: false,
          );

          if (compressedVideo != null && compressedVideo.file != null) {
            customerProvider.setSelectedVideo(compressedVideo.file!);
          }
        } finally {
          customerProvider.setLoadingVideo(false);
        }
      }

    } catch (e) {
      customerProvider.setLoadingVideo(false);
      _showErrorSnackBar('Error recording instant video: $e');
    } finally {
      customerProvider.setRecordingVideo(false);
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
        customerProvider.setRecording(true);

        final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        final directory = Directory.systemTemp;
        final filePath = '${directory.path}/$fileName';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );
        final customerAudioProvider = Provider.of<CustomerProvider>(context, listen: false);
        customerAudioProvider.setAudioPath(filePath);

        print('🎵 [AUDIO] Recording started with path: $filePath');
        print('🎵 [AUDIO] Audio path set: ${customerAudioProvider.audioPath}');

        _startDurationTimer();
      } else {
        _showErrorSnackBar('Microphone permission denied');
      }
    } catch (e) {
      final customerProviderError = Provider.of<CustomerProvider>(context, listen: false);
      customerProviderError.setRecording(false);
      _showErrorSnackBar('Error starting recording: $e');
    }
  }

  void _startDurationTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      if (customerProvider.isRecording) {
        customerProvider.updateRecordingDuration(
          Duration(seconds: customerProvider.recordingDuration.inSeconds + 1)
        );
        _startDurationTimer();
      }
    });
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();

      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      customerProvider.setRecording(false);

      print('📊 [AUDIO] Recording stopped with optimized compression settings');
      print('🎵 [AUDIO] Audio path: ${customerProvider.audioPath}');
      print('🎵 [AUDIO] Is recording: ${customerProvider.isRecording}');
    } catch (e) {
      final customerAudioProvider = Provider.of<CustomerProvider>(context, listen: false);
      customerAudioProvider.setRecording(false);
      _showErrorSnackBar('Error stopping/processing recording: $e');
    }
  }



  Future<void> _playAudio() async {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    if (customerProvider.audioPath == null) return;
    
    try {
      if (customerProvider.isPlaying) {
        await _audioPlayer.stop();
        customerProvider.setPlaying(false);
      } else {
        await _audioPlayer.play(DeviceFileSource(customerProvider.audioPath!));
        customerProvider.setPlaying(true);
        
        _audioPlayer.onPlayerComplete.listen((_) {
          customerProvider.setPlaying(false);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error playing audio: $e');
    }
  }



  Future<void> _submitJob() async {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    
    if (customerProvider.titleController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a job title');
      return;
    }

    if (customerProvider.descriptionController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a job description');
      return;
    }

    if (customerProvider.addressController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter an address');
      return;
    }

    if (customerProvider.selectedServiceKey == null) {
      _showErrorSnackBar('Please select a service type');
      return;
    }

    final feeText = customerProvider.feeController.text.trim();
    if (feeText.isEmpty) {
      _showErrorSnackBar('Please enter a fee range');
      return;
    }

    final feeRange = _parseFeeRange(feeText);
    if (feeRange == null) {
      _showErrorSnackBar('Please enter a valid fee range (e.g., 500-800)');
      return;
    }

    final minFee = feeRange['min'];
    final maxFee = feeRange['max'];

    if (minFee! <= 0 || maxFee! <= 0) {
      _showErrorSnackBar('Fee amounts must be greater than 0');
      return;
    }

    if (minFee >= maxFee) {
      _showErrorSnackBar('Minimum fee must be less than maximum fee');
      return;
    }

    customerProvider.setLoading(true);

    try {
      final token = await ApiService.getJwtToken();
      if (token == null) {
        _showErrorSnackBar('Please login to post a job');
        customerProvider.setLoading(false);
        return;
      }

      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        
        await Future.delayed(const Duration(seconds: 2));
        
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _showErrorSnackBar('GPS is not enabled. Please enable location services and try again.');
          customerProvider.setLoading(false);
          return;
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar('Location permission denied. Please allow location access and try again.');
          customerProvider.setLoading(false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar('Location permission permanently denied. Please enable location access in settings.');
        customerProvider.setLoading(false);
        return;
      }

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (e) {
        _showErrorSnackBar('Unable to get your current location. Please try again.');
        customerProvider.setLoading(false);
        return;
      }

      final lat = position.latitude;
      final lng = position.longitude;


      final result = await ApiService.createJob(
        title: customerProvider.titleController.text.trim(),
        description: customerProvider.descriptionController.text.trim(),
        address: customerProvider.addressController.text.trim(),
        token: token,
        minFee: minFee,
        maxFee: maxFee,
        serviceKey: customerProvider.selectedServiceKey!,
        imagePath: customerProvider.selectedImage?.path,
        videoPath: customerProvider.selectedVideo?.path,
        audioPath: customerProvider.audioPath,
        latitude: lat,
        longitude: lng,
      );

      customerProvider.setLoading(false);

      if (result['success']) {
        // Clear all fields through provider
        customerProvider.clearAllFields();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text("Success"),
              content: const Text("Your job has been posted successfully!"),
            );
          },
        );

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ServiceSearchPage()),
            );
          }
        });
      } else {
        _showErrorSnackBar(result['error'] ?? 'Failed to post job');
      }

    } catch (e, stackTrace) {
      customerProvider.setLoading(false);
      _showErrorSnackBar('Error: $e');
    }
  }


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }





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


  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8DD4FD), Color(0xFF547F97)],
          stops: [0.01, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Post a job ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                                color: Colors.black,
                              ),
                            ),
                            Icon(
                              Icons.more_vert,
                              size: 28,
                              color: Color(0xff25B0F0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Job Title",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: customerProvider.titleController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Enter job title",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8DD4FD),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8DD4FD),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Job Description",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: customerProvider.descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Describe the job requirements",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8DD4FD),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8DD4FD),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Service Type",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<int>(
                            value: customerProvider.selectedServiceKey,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Select service type",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8DD4FD),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8DD4FD),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            ),
                            items: customerProvider.allServiceOptions.entries.map((entry) {
                              return DropdownMenuItem<int>(
                                value: entry.value,
                                child: Text(entry.key),
                              );
                            }).toList(),
                            onChanged: (int? value) {
                              customerProvider.setSelectedServiceKey(value);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Upload Media",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        if (customerProvider.selectedImage != null || customerProvider.selectedVideo != null)
                          Stack(
                            children: [
                              Container(
                                height: 186,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: customerProvider.selectedImage != null
                                      ? Image.file(
                                          customerProvider.selectedImage!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      : customerProvider.selectedVideo != null
                                          ? Stack(
                                              children: [
                                                // Video thumbnail placeholder
                                                Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  color: Colors.black87,
                                                  child: const Icon(
                                                    Icons.videocam,
                                                    color: Colors.white,
                                                    size: 50,
                                                  ),
                                                ),
                                                // Play button overlay
                                                const Center(
                                                  child: Icon(
                                                    Icons.play_circle_filled,
                                                    color: Colors.white,
                                                    size: 60,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const SizedBox(),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: _clearMedia,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        
                        const SizedBox(height: 15),
                        
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: const Color(0xff8DD4FD), width: 1.5),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        color: Color(0xff8DD4FD),
                                        size: 24,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Image',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xff8DD4FD),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            
                            Expanded(
                              child: GestureDetector(
                                onTap: customerProvider.isLoadingVideo ? null : _pickVideo,
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: customerProvider.isLoadingVideo 
                                        ? Colors.grey.withOpacity(0.1) 
                                        : Colors.white,
                                    border: Border.all(
                                      color: customerProvider.isLoadingVideo 
                                          ? Colors.grey 
                                          : const Color(0xff8DD4FD), 
                                      width: 1.5
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: customerProvider.isLoadingVideo
                                      ? const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff8DD4FD)),
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Processing...',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff8DD4FD),
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.video_library,
                                              color: Color(0xff8DD4FD),
                                              size: 24,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Video (15s)',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff8DD4FD),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            
                            Expanded(
                              child: GestureDetector(
                                onTap: (customerProvider.isRecordingVideo || customerProvider.isLoadingVideo) ? null : _recordInstantVideo,
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: (customerProvider.isRecordingVideo || customerProvider.isLoadingVideo)
                                        ? Colors.red.withOpacity(0.1) 
                                        : Colors.white,
                                    border: Border.all(
                                      color: (customerProvider.isRecordingVideo || customerProvider.isLoadingVideo)
                                          ? Colors.red 
                                          : const Color(0xff8DD4FD), 
                                      width: 1.5
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: (customerProvider.isRecordingVideo || customerProvider.isLoadingVideo)
                                      ? const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Processing...',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.videocam,
                                              color: Color(0xff8DD4FD),
                                              size: 24,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Record',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff8DD4FD),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Container(
                          constraints: BoxConstraints(
                            minHeight: 60,
                            maxHeight: customerProvider.audioPath != null ? 120 : 80,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: customerProvider.isRecording ? Colors.red.withOpacity(0.1) : Colors.white,
                            border: Border.all(
                              color: customerProvider.isRecording ? Colors.red : const Color(0xff8DD4FD), 
                              width: 1.5
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: customerProvider.isRecording ? _stopRecording : _startRecording,
                                    child: Icon(
                                      customerProvider.isRecording ? Icons.stop_circle : Icons.mic, 
                                      color: customerProvider.isRecording ? Colors.red : Colors.black,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: customerProvider.isRecording
                                        ? Row(
                                            children: [
                                              const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Recording... ${customerProvider.formatDuration(customerProvider.recordingDuration)}',
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            customerProvider.audioPath != null 
                                                ? 'Audio recorded (${customerProvider.formatDuration(customerProvider.recordingDuration)})'
                                                : 'Tap to record audio',
                                            style: TextStyle(
                                              color: customerProvider.audioPath != null ? Colors.green : Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                  ),
                                  if (customerProvider.audioPath != null && !customerProvider.isRecording) ...[
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: _deleteAudio,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (customerProvider.audioPath != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: _playAudio,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: customerProvider.isPlaying ? Colors.red : Colors.green,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              customerProvider.isPlaying ? Icons.stop : Icons.play_arrow,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              customerProvider.isPlaying ? 'Stop' : 'Play',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Address",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: customerProvider.addressController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8DD4FD),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8DD4FD),
                                  width: 2,
                                ),
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(width: 120, child: Divider(color: Colors.black26, thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text("or", style: TextStyle(color: Colors.black54)),
                            ),
                            SizedBox(width: 120, child: Divider(color: Colors.black26, thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Center(
                          child: Text(
                            "Choose on Map",
                            style: TextStyle(
                              color: Color(0xff70D2FF),
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xff70D2FF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Fee Range",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: customerProvider.feeController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Enter fee range (e.g., 500-800 or 1000-1500)",
                              prefixText: "Rs. ",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8DD4FD),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8DD4FD),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Center(
                          child: ElevatedButton(
                            onPressed: customerProvider.isLoading ? null : _submitJob,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: customerProvider.isLoading 
                                  ? Colors.grey 
                                  : const Color(0xff25B0F0),
                              minimumSize: const Size(200, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: customerProvider.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    "Submit Request",
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ],

          ),

        ),


      ),
    );
      },
    );
  }
}
