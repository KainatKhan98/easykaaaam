import 'dart:async';
import 'dart:convert';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;
  SignalRService._internal();

  HubConnection? _connection;
  final String _hubUrl = 'https://easy-kaam-48281873f974.herokuapp.com/chatHub';
  
  // Stream controllers for real-time updates
  final StreamController<ChatMessage> _messageController = StreamController<ChatMessage>.broadcast();
  final StreamController<String> _connectionStatusController = StreamController<String>.broadcast();
  
  // Getters for streams
  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<String> get connectionStatusStream => _connectionStatusController.stream;
  
  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  Future<void> initializeConnection() async {
    try {
      _connection = HubConnectionBuilder()
          .withUrl(_hubUrl)
          .withAutomaticReconnect()
          .build();

      // Set up event handlers
      _setupEventHandlers();

      // Start connection
      await _connection!.start();
      _connectionStatusController.add('Connected');
      
      print('SignalR connection established');
    } catch (e) {
      print('Error initializing SignalR connection: $e');
      _connectionStatusController.add('Connection failed: $e');
    }
  }

  void _setupEventHandlers() {
    if (_connection == null) return;

    // Listen for incoming messages
    _connection!.on('ReceiveMessage', (List<Object?>? arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final messageData = arguments[0] as Map<String, dynamic>;
          final message = ChatMessage.fromJson(messageData);
          _messageController.add(message);
        } catch (e) {
          print('Error parsing incoming message: $e');
        }
      }
    });

    // Listen for connection state changes
    _connection!.onclose(({Exception? error}) {
      _connectionStatusController.add('Disconnected');
      print('SignalR connection closed: $error');
    });

    _connection!.onreconnecting(({Exception? error}) {
      _connectionStatusController.add('Reconnecting...');
      print('SignalR reconnecting: $error');
    });

    _connection!.onreconnected(({String? connectionId}) {
      _connectionStatusController.add('Reconnected');
      print('SignalR reconnected with connection ID: $connectionId');
    });
  }

  Future<void> joinChatGroup(String groupName) async {
    if (_connection?.state == HubConnectionState.Connected) {
      try {
        await _connection!.invoke('JoinGroup', args: [groupName]);
        print('Joined chat group: $groupName');
      } catch (e) {
        print('Error joining chat group: $e');
      }
    }
  }

  Future<void> leaveChatGroup(String groupName) async {
    if (_connection?.state == HubConnectionState.Connected) {
      try {
        await _connection!.invoke('LeaveGroup', args: [groupName]);
        print('Left chat group: $groupName');
      } catch (e) {
        print('Error leaving chat group: $e');
      }
    }
  }

  Future<void> sendMessage(String receiverId, String message, String messageType) async {
    if (_connection?.state == HubConnectionState.Connected) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final senderId = prefs.getString('userId') ?? '';
        
        await _connection!.invoke('SendMessage', args: [
          senderId,
          receiverId,
          message,
          messageType,
          DateTime.now().toIso8601String()
        ]);
        print('Message sent successfully');
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  Future<void> sendVoiceMessage(String receiverId, String voiceMessagePath) async {
    if (_connection?.state == HubConnectionState.Connected) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final senderId = prefs.getString('userId') ?? '';
        
        await _connection!.invoke('SendVoiceMessage', args: [
          senderId,
          receiverId,
          voiceMessagePath,
          DateTime.now().toIso8601String()
        ]);
        print('Voice message sent successfully');
      } catch (e) {
        print('Error sending voice message: $e');
      }
    }
  }

  Future<void> disconnect() async {
    if (_connection != null) {
      await _connection!.stop();
      _connection = null;
      _connectionStatusController.add('Disconnected');
    }
  }

  void dispose() {
    _messageController.close();
    _connectionStatusController.close();
    disconnect();
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String messageType;
  final DateTime timestamp;
  final bool isFromCurrentUser;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.messageType,
    required this.timestamp,
    required this.isFromCurrentUser,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isFromCurrentUser: false, // This will be set based on current user context
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'messageType': messageType,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
