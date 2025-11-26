import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/chatbot_remote_data_source.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemoteDataSource remoteDataSource;

  ChatbotRepositoryImpl({ChatbotRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? ChatbotRemoteDataSourceImpl();

  @override
  Future<void> sendMessage(String message) async {
    await remoteDataSource.sendMessage(message);
  }

  @override
  Future<List<ChatMessage>> getChatHistory() async {
    // n8n maneja el historial internamente
    return [];
  }
}

