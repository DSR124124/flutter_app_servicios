import 'package:flutter/foundation.dart';
import '../../domain/repositories/chatbot_repository.dart';

class ChatbotProvider extends ChangeNotifier {
  final ChatbotRepository repository;
  bool _isLoading = false;
  String? _error;

  ChatbotProvider({required this.repository});

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendMessage(String message) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.sendMessage(message);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

