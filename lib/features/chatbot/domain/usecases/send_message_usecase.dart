import '../repositories/chatbot_repository.dart';

class SendMessageUseCase {
  final ChatbotRepository repository;

  SendMessageUseCase(this.repository);

  Future<void> call(String message) async {
    return await repository.sendMessage(message);
  }
}

