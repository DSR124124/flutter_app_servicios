import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_config.dart';

abstract class ChatbotRemoteDataSource {
  Future<Map<String, dynamic>> sendMessage(String message, {String? sessionId});
}

class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  final http.Client client;

  ChatbotRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<Map<String, dynamic>> sendMessage(
    String message, {
    String? sessionId,
  }) async {
    final url = Uri.parse('${AppConfig.n8nChatWebhookUrl}?action=sendMessage');
    
    final body = jsonEncode({
      'chatInput': message,
      if (sessionId != null) 'sessionId': sessionId,
    });

    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      // n8n devuelve la respuesta directamente
      return {'response': response.body};
    } else {
      throw Exception('Error al enviar mensaje: ${response.statusCode}');
    }
  }
}

