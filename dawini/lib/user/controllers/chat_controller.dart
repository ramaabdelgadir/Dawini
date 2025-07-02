import 'package:dawini/user/controllers/user_cloud_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatController {
  static final ChatController _instance = ChatController._internal();
  factory ChatController() => _instance;
  ChatController._internal();

  final CloudController _cloudController = CloudController();
  final http.Client _client = http.Client();
  final String apiBaseUrl =
      'https://8000-dep-01jywqr3484cy10dx1gxz7mhha-d.cloudspaces.litng.ai';
  final String _authToken = 'Bearer d8856783-7ef2-48eb-96eb-1114ca776e14';

  Future<String> initializeChat() async {
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
    final apiUrl = '$apiBaseUrl/generate-answer/';
    final userId = _cloudController.userID;
    final chatId = _cloudController.currentChatID;

    if (chatId == null) {
      return 'خطأ: لا يمكن تحديد المحادثة.';
    }

    try {
      // Fetch messages from Firestore (ordered by timestamp ascending)
      final messagesSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .orderBy('timestamp')
              .get();

      final chatHistory = <Map<String, String>>[];

      chatHistory.add({
        'role': 'system',
        'content':
            'You are an expert artificial intelligence-based Arabic medical chatbot named Dawini depends on reliable medical knowledge to answer patient medical questions. Answer the last question sent by the user considering all previous chat history.',
      });

      for (final doc in messagesSnapshot.docs) {
        final data = doc.data();
        final sender = (data['sender'] ?? '').toString().toLowerCase();
        final text = (data['text'] ?? '').toString().trim();

        if (text.isEmpty) continue;

        chatHistory.add({
          'role': sender == 'user' ? 'user' : 'assistant',
          'content': text,
        });
      }

      // Compose the request body
      final body = {'prompt': userMessage, 'chat_history': chatHistory};

      print('Sending POST request to $apiUrl with body: $body');

      final response = await _client.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _authToken,
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['answer']?.toString() ?? 'حدث خطأ في تلقي الرد.';
      } else {
        return 'حدث خطأ في الاتصال: ${response.statusCode}';
      }
    } catch (e, stack) {
      print('Error calling AI API: $e');
      print(stack);
      return 'حدث خطأ أثناء الاتصال بالذكاء الاصطناعي:\n$e';
    }
  }
}
