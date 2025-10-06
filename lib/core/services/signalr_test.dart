import 'signalr_service.dart';

// Simple test to verify SignalR service compiles and initializes correctly
void testSignalRService() async {
  final signalRService = SignalRService();
  
  // Test initialization
  await signalRService.initializeConnection();
  
  // Test message sending
  await signalRService.sendMessage('test-receiver', 'Hello World', 'text');
  
  // Test voice message sending
  await signalRService.sendVoiceMessage('test-receiver', '/path/to/voice.wav');
  
  // Test group operations
  await signalRService.joinChatGroup('test-group');
  await signalRService.leaveChatGroup('test-group');
  
  // Test disconnection
  await signalRService.disconnect();
  
  print('SignalR service test completed successfully!');
}

