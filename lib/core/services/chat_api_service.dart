import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatApiService {
  static final ChatApiService _instance = ChatApiService._internal();
  factory ChatApiService() => _instance;
  ChatApiService._internal();

  final Dio _dio = Dio();
  final String _baseUrl = 'https://easy-kaam-48281873f974.herokuapp.com';

  Future<void> _setAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Map<String, dynamic>> sendVoiceMessage({
    required String senderId,
    required String receiverId,
    required File voiceFile,
  }) async {
    try {
      await _setAuthHeaders();
      
      FormData formData = FormData.fromMap({
        'senderId': senderId,
        'receiverId': receiverId,
        'voiceMessage': await MultipartFile.fromFile(
          voiceFile.path,
          filename: 'voice_message_${DateTime.now().millisecondsSinceEpoch}.wav',
        ),
      });

      final response = await _dio.post(
        '$_baseUrl/api/communication/send-voice-message',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'accept': '*/*',
          },
        ),
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Voice message sent successfully',
      };
    } catch (e) {
      print('Error sending voice message: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to send voice message',
      };
    }
  }

  Future<Map<String, dynamic>> getAllUserMessages({
    required String senderId,
    required String receiverId,
    int pageNumber = 1,
    int pageSize = 15,
  }) async {
    try {
      await _setAuthHeaders();
      
      final response = await _dio.get(
        '$_baseUrl/api/communication/get-all-user-messages',
        queryParameters: {
          'PageNumber': pageNumber,
          'PageSize': pageSize,
          'SenderId': senderId,
          'ReceiverId': receiverId,
        },
        options: Options(
          headers: {
            'accept': '*/*',
          },
        ),
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Messages retrieved successfully',
      };
    } catch (e) {
      print('Error getting messages: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to retrieve messages',
      };
    }
  }

  Future<Map<String, dynamic>> getChatHistory({
    required String userId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      await _setAuthHeaders();
      
      final response = await _dio.get(
        '$_baseUrl/api/communication/get-chat-history',
        queryParameters: {
          'userId': userId,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Chat history retrieved successfully',
      };
    } catch (e) {
      print('Error getting chat history: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to retrieve chat history',
      };
    }
  }

  Future<Map<String, dynamic>> markMessageAsRead({
    required String messageId,
    required String userId,
  }) async {
    try {
      await _setAuthHeaders();
      
      final response = await _dio.put(
        '$_baseUrl/api/communication/mark-message-read',
        data: {
          'messageId': messageId,
          'userId': userId,
        },
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Message marked as read',
      };
    } catch (e) {
      print('Error marking message as read: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to mark message as read',
      };
    }
  }
}

