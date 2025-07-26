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
  final String _apiUrl =
      'https://8000-dep-01jywqr3484cy10dx1gxz7mhha-d.cloudspaces.litng.ai/generate-answer/';
  final String _authToken = 'Bearer d8856783-7ef2-48eb-96eb-1114ca776e14';

  Future<String> startNewChat() async {
    await _cloudController.startNewChat();
    return _cloudController.currentChatID!;
  }

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
    final userId = _cloudController.userID;
    final chatId = _cloudController.currentChatID;

    if (chatId == null) return 'خطأ: لا يمكن تحديد المحادثة.';

    try {
      final messagesSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .orderBy('timestamp')
              .get();

      final chatHistory = <Map<String, String>>[
        {
          "role": "system",
          "content":
              "أنت روبوت دردشة طبي متخصص وذكي يُدعى ( 'داويني ')، مدعوم بالذكاء الاصطناعي، وتعتمد إجاباتك على معلومات طبية موثوقة. مهمتك هي فهم وتحليل السؤال الطبي المُرسل من المستخدم، ثم تقديم إجابة واضحة، مفيدة، وآمنة طبياً. احرص دائماً على: تقديم معلومات موثوقة بلغة مبسطة يفهمها المريض. التنبيه إلى ضرورة مراجعة الطبيب عند الحاجة.  إذا بدأ المستخدم الرسالة بتحية أو رسالة قصيرة مثل  'السلام عليكم ' أو  'مرحباً '، فابدأ برد مهذب وقصير فقط دون زيادة, أجب عن آخر سؤال طبي طرحه المستخدم مع مراعاة جميع الرسائل السابقة في المحادثة.",
        },
      ];

      final docs = messagesSnapshot.docs;

      for (int i = 0; i < docs.length; i++) {
        final data = docs[i].data();
        final sender = (data['sender'] ?? '').toString().toLowerCase();
        final text = (data['text'] ?? '').toString().trim();
        if (text.isEmpty) continue;

        final isLast = i == docs.length - 1;
        final isUser = sender == "user";
        final isDuplicate = text == userMessage;
        if (isLast && isUser && isDuplicate) continue;

        chatHistory.add({
          "role": isUser ? "user" : "assistant",
          "content": text,
        });
      }

      final body = {'prompt': userMessage, 'chat_history': chatHistory};

      final response = await _client.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _authToken,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['answer']?.toString() ?? 'حدث خطأ في تلقي الرد.';
      } else {
        return 'حدث خطأ في الاتصال: ${response.statusCode}';
      }
    } catch (e) {
      return 'حدث خطأ أثناء الاتصال بالذكاء الاصطناعي:\n$e';
    }
  }
}
