import '../entities/chat_message.dart';

abstract class ChatbotRepository {
  Future<void> sendMessage(String message);
  Future<List<ChatMessage>> getChatHistory();
}

