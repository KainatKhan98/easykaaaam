import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:io';

import '../../../../../core/services/chat_api_service.dart';
import '../../../../../core/services/signalr_service.dart';

class GetMessageChat extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  
  const GetMessageChat({
    Key? key,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  State<GetMessageChat> createState() => _GetMessageChatState();
}

class _GetMessageChatState extends State<GetMessageChat> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final SignalRService _signalRService = SignalRService();
  final ChatApiService _apiService = ChatApiService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isRecording = false;
  bool _isConnected = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
    
    await _signalRService.initializeConnection();
    
    _signalRService.connectionStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _isConnected = status == 'Connected';
        });
      }
    });
    
    _signalRService.messageStream.listen((message) {
      if (mounted) {
        setState(() {
          _messages.add(message);
        });
      }
    });
    
    await _loadMessageHistory();
  }

  Future<void> _loadMessageHistory() async {
    if (_currentUserId == null) return;
    
    final result = await _apiService.getAllUserMessages(
      senderId: _currentUserId!,
      receiverId: widget.receiverId,
    );
    
    if (result['success'] && mounted) {
      setState(() {
        
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty && _isConnected) {
      await _signalRService.sendMessage(
        widget.receiverId,
        _messageController.text.trim(),
        'text',
      );
      _messageController.clear();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (_isRecording) return;
      
      final permission = await Permission.microphone.request();
      
      if (permission != PermissionStatus.granted) {
        _showPermissionDialog();
        return;
      }

      if (!await _audioRecorder.hasPermission()) {
        _showPermissionDialog();
        return;
      }

      if (await _audioRecorder.isRecording()) {
        print('Recorder is already recording');
        return;
      }

      final directory = Directory.systemTemp;
      final path = '${directory.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      
      setState(() {
        _isRecording = true;
      });
      
      print('Recording started: $path');
    } catch (e) {
      print('Error starting recording: $e');
      _showErrorDialog('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (!_isRecording) return;
      
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
      
      if (path != null && _isConnected) {
        final file = File(path);
        if (await file.exists()) {
          await _signalRService.sendVoiceMessage(widget.receiverId, path);
          print('Voice message sent: $path');
        } else {
          _showErrorDialog('Recording file not found');
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() {
        _isRecording = false;
      });
      _showErrorDialog('Failed to stop recording: $e');
    }
  }

  Future<void> _playVoiceMessage(String filePath) async {
    try {
      await _audioPlayer.play(DeviceFileSource(filePath));
    } catch (e) {
      print('Error playing voice message: $e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'This app needs microphone permission to record voice messages. '
          'Please grant permission in the app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isConnected ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _signalRService.disconnect();
                  Navigator.pop(context);
                },
              )
            ],
          ),
          const Divider(),

          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isFromCurrentUser = message.senderId == _currentUserId;
                
                return Align(
                  alignment: isFromCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isFromCurrentUser ? Colors.blue[500] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.messageType == 'voice')
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle_filled,
                                color: isFromCurrentUser ? Colors.white : Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Voice Message',
                                style: TextStyle(
                                  color: isFromCurrentUser ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            message.content,
                            style: TextStyle(
                              color: isFromCurrentUser ? Colors.white : Colors.black,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: isFromCurrentUser ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Row(
            children: [
              GestureDetector(
                onTapDown: (_) => _startRecording(),
                onTapUp: (_) => _stopRecording(),
                onTapCancel: () => _stopRecording(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: _isRecording ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isConnected ? _sendMessage : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
