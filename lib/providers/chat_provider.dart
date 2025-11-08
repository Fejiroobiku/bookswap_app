import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../models/message.dart';

class ChatProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  Map<String, List<Message>> _chats = {};
  bool _isLoading = false;

  ChatProvider(this._firestoreService);

  bool get isLoading => _isLoading;
  List<Message> getChatMessages(String chatId) => _chats[chatId] ?? [];

  Stream<List<Message>> getChatStream(String chatId) {
    return _firestoreService.getChatMessages(chatId);
  }

  Future<void> loadChatMessages(String chatId) async {
    _firestoreService.getChatMessages(chatId).listen((messages) {
      _chats[chatId] = messages;
      notifyListeners();
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    await _firestoreService.sendMessage(message);
  }

  Future<String> getOrCreateChatId(String user1Id, String user2Id) async {
    return await _firestoreService.getOrCreateChatId(user1Id, user2Id);
  }
}