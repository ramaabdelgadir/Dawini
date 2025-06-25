import 'package:dawini/user/controllers/user_cloud_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatController {
  // Singleton setup
  static final ChatController _instance = ChatController._internal();
  factory ChatController() => _instance;
  ChatController._internal();

  final CloudController _cloudController = CloudController();
  String? apiBaseUrl;

  Future<void> _initApiUrl() async {
    if (apiBaseUrl != null && apiBaseUrl!.isNotEmpty) return;

    final doc =
        await FirebaseFirestore.instance.collection('config').doc('api').get();

    if (doc.exists) {
      final data = doc.data();
      apiBaseUrl = data?['apiUrl'] as String?;
    }
  }

  Future<String> initializeChat() async {
    await _initApiUrl();

    if (_cloudController.currentChatID == null) {
      await _cloudController.startNewChat();
    }
    return _cloudController.currentChatID!;
  }

  void setCurrentChatID(String chatID) {
    _cloudController.setCurrentChatID(chatID);
  }

  Future<void> addMessage(String message, String sender) async {
    await _cloudController.sendMessage(message, sender);
  }

  Stream<QuerySnapshot> getMessages() {
    return _cloudController.getMessages();
  }

  Future<String> getAIResponse(String userMessage) async {
    if (apiBaseUrl == null || apiBaseUrl!.isEmpty) {
      return 'Error: API base URL is not set.';
    }

    final apiUrl = '${apiBaseUrl!}/generate';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['response']?.toString() ?? 'No response from AI.';
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return '$e (Error connecting to AI) ';
    }
  }
}
