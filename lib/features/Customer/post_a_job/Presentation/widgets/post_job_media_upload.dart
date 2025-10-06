import 'package:flutter/material.dart';
import 'dart:io';

class PostJobMediaUpload extends StatelessWidget {
  final File? selectedImage;
  final File? selectedVideo;
  final VoidCallback onImageTap;
  final VoidCallback onVideoTap;
  final VoidCallback onRecordTap;
  final VoidCallback onClearMedia;
  final bool isRecordingVideo;

  const PostJobMediaUpload({
    super.key,
    this.selectedImage,
    this.selectedVideo,
    required this.onImageTap,
    required this.onVideoTap,
    required this.onRecordTap,
    required this.onClearMedia,
    this.isRecordingVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Media",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        
        if (selectedImage != null || selectedVideo != null)
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
                  child: selectedImage != null
                      ? Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : selectedVideo != null
                          ? Stack(
                              children: [
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
                  onTap: onClearMedia,
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
                onTap: onImageTap,
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
                onTap: onVideoTap,
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
                onTap: isRecordingVideo ? null : onRecordTap,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: isRecordingVideo 
                        ? Colors.red.withOpacity(0.1) 
                        : Colors.white,
                    border: Border.all(
                      color: isRecordingVideo 
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
                  child: isRecordingVideo
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
                              'Recording...',
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
      ],
    );
  }
}

