import 'package:cloud_firestore/cloud_firestore.dart';

class UserCloudModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeMessage(
    String userUID,
    String chatID,
    String message,
    String sender,
  ) async {
    try {
      DocumentReference chatRef = _firestore
          .collection('users')
          .doc(userUID)
          .collection('chats')
          .doc(chatID);

      await chatRef.collection('messages').add({
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
        'sender': sender, // 'User' or 'AI'
      });
    } catch (e) {
      print('Error storing message: $e');
    }
  }

  Stream<QuerySnapshot> getMessages(String userUID, String chatID) {
    return _firestore
        .collection('users')
        .doc(userUID)
        .collection('chats')
        .doc(chatID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getChatHistory(String userUID) {
    return _firestore
        .collection('users')
        .doc(userUID)
        .collection('chats')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<DocumentReference> startNewChat(String userUID) async {
    try {
      DocumentReference chatRef = await _firestore
          .collection('users')
          .doc(userUID)
          .collection('chats')
          .add({'createdAt': FieldValue.serverTimestamp()});
      return chatRef;
    } catch (e) {
      print('Error starting new chat: $e');
      rethrow;
    }
  }

  Future<void> deleteChat(String userUID, String chatID) async {
    try {
      await _firestore
          .collection('users')
          .doc(userUID)
          .collection('chats')
          .doc(chatID)
          .delete();
      print('Chat deleted successfully');
    } catch (e) {
      print('Error deleting chat: $e');
    }
  }

  Future<void> deleteAllChats(String userUID) async {
    try {
      var chatsSnapshot =
          await _firestore
              .collection('users')
              .doc(userUID)
              .collection('chats')
              .get();
      if (chatsSnapshot.docs.isEmpty) {
        print('No chats to delete');
        return;
      }

      for (var doc in chatsSnapshot.docs) {
        await doc.reference.delete();
      }
      print('All chats deleted successfully');
    } catch (e) {
      print('Error deleting all chats: $e');
    }
  }

  Future<bool> isChatEmpty(String userUID, String chatID) async {
    try {
      final messagesSnapshot =
          await _firestore
              .collection('users')
              .doc(userUID)
              .collection('chats')
              .doc(chatID)
              .collection('messages')
              .get();
      return messagesSnapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking if chat is empty: $e');
      return true;
    }
  }
}
