import '../models/user_cloud_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CloudController extends ChangeNotifier {
  final UserCloudModel _userCloudModel = UserCloudModel();
  String? _currentChatID;
  String? get currentChatID => _currentChatID;
  String get userID => FirebaseAuth.instance.currentUser!.uid;
  void setCurrentChatID(String chatID) {
    _currentChatID = chatID;
    notifyListeners();
  }

  Future<void> startNewChat() async {
    final userUID = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference chatRef = await _userCloudModel.startNewChat(userUID);
    setCurrentChatID(chatRef.id);
  }

  Future<void> sendMessage(String message, String sender) async {
    try {
      if (_currentChatID == null) {
        print('No active chat found to store the message');
        return;
      }
      final userUID = FirebaseAuth.instance.currentUser!.uid;
      await _userCloudModel.storeMessage(
        userUID,
        _currentChatID!,
        message,
        sender,
      );
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Stream<QuerySnapshot> getMessages() {
    if (_currentChatID == null) {
      print('No active chat found');
    }
    final userUID = FirebaseAuth.instance.currentUser!.uid;
    return _userCloudModel.getMessages(userUID, _currentChatID!);
  }

  Stream<QuerySnapshot> getChatHistory() {
    try {
      final userUID = FirebaseAuth.instance.currentUser!.uid;
      return _userCloudModel.getChatHistory(userUID);
    } catch (e) {
      print('Error fetching chat history: $e');
      rethrow;
    }
  }

  Future<void> deleteChat(String chatID) async {
    final userUID = FirebaseAuth.instance.currentUser!.uid;
    await _userCloudModel.deleteChat(userUID, chatID);
  }

  Future<void> deleteAllChats() async {
    final userUID = FirebaseAuth.instance.currentUser!.uid;
    await _userCloudModel.deleteAllChats(userUID);
  }

  Future<void> cleanupUnusedChats(String? currentChatID) async {
    try {
      final userUID = FirebaseAuth.instance.currentUser!.uid;
      final chatsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userUID)
          .collection('chats');
      final docs = (await chatsRef.get()).docs;

      List<DocumentSnapshot> emptyChats = [];
      for (var doc in docs) {
        if (await _userCloudModel.isChatEmpty(userUID, doc.id)) {
          emptyChats.add(doc);
        }
      }
      if (emptyChats.isEmpty) return;

      emptyChats.sort((a, b) {
        final aCreated = a.get('createdAt') as Timestamp;
        final bCreated = b.get('createdAt') as Timestamp;
        return bCreated.compareTo(aCreated);
      });

      if (currentChatID != null) {
        emptyChats.removeWhere((doc) => doc.id == currentChatID);
      }

      if (emptyChats.length > 1) {
        for (var doc in emptyChats.skip(1)) {
          await deleteChat(doc.id);
          print('Deleted unused empty chat: ${doc.id}');
        }
      }
    } catch (e) {
      print('Error cleaning up unused chats: $e');
    }
  }
}
