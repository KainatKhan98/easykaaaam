import 'package:flutter/material.dart';

class PostJobAudioRecorder extends StatelessWidget {
  final bool isRecording;
  final bool isPlaying;
  final String? audioPath;
  final Duration recordingDuration;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onPlayAudio;
  final VoidCallback onDeleteAudio;

  const PostJobAudioRecorder({
    super.key,
    required this.isRecording,
    required this.isPlaying,
    this.audioPath,
    required this.recordingDuration,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onPlayAudio,
    required this.onDeleteAudio,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 60,
        maxHeight: audioPath != null ? 120 : 80,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isRecording ? Colors.red.withOpacity(0.1) : Colors.white,
        border: Border.all(
          color: isRecording ? Colors.red : const Color(0xff8DD4FD), 
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
                onTap: isRecording ? onStopRecording : onStartRecording,
                child: Icon(
                  isRecording ? Icons.stop_circle : Icons.mic, 
                  color: isRecording ? Colors.red : Colors.black,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isRecording
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
                              'Recording... ${_formatDuration(recordingDuration)}',
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
                        audioPath != null 
                            ? 'Audio recorded (${_formatDuration(recordingDuration)})'
                            : 'Tap to record audio',
                        style: TextStyle(
                          color: audioPath != null ? Colors.green : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              if (audioPath != null && !isRecording) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDeleteAudio,
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
          if (audioPath != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onPlayAudio,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isPlaying ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPlaying ? Icons.stop : Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPlaying ? 'Stop' : 'Play',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

