import 'package:dawini/user/controllers/user_cloud_controller.dart';
import 'package:flutter/material.dart';

class ChatHistoryController extends ChangeNotifier {
  final CloudController _cloudController = CloudController();
  String? _currChatID;
  String? get currChatID => _currChatID;

  void getCurrentChatID(String? chatID) {
    _currChatID = chatID;
    notifyListeners();
  }

  ValueNotifier<List<String>> chatHistoryNotifier = ValueNotifier([]);

  void loadChatHistory() async {
    await _cloudController.cleanupUnusedChats(_currChatID);

    _cloudController.getChatHistory().listen((snapshot) {
      List<String> chatTitles = snapshot.docs.map((doc) => doc.id).toList();
      chatHistoryNotifier.value = chatTitles;
    });
    notifyListeners();
  }

  void deleteChat(int index) async {
    final chatID = chatHistoryNotifier.value[index];
    await _cloudController.deleteChat(chatID);
    loadChatHistory();
  }

  void deleteAllChats() async {
    await _cloudController.deleteAllChats();
    loadChatHistory();
  }

  String openChat(int index) {
    final chatID = chatHistoryNotifier.value[index];
    _cloudController.setCurrentChatID(chatID);
    return chatID;
  }
}
