import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthRepository? repository,
    LoginUseCase? loginUseCase,
    LogoutUseCase? logoutUseCase,
    GetCurrentUserUseCase? getCurrentUserUseCase,
  }) : this._internal(
         repository ?? AuthRepositoryImpl(),
         loginUseCase,
         logoutUseCase,
         getCurrentUserUseCase,
       );

  AuthProvider._internal(
    AuthRepository repository,
    LoginUseCase? loginUseCase,
    LogoutUseCase? logoutUseCase,
    GetCurrentUserUseCase? getCurrentUserUseCase,
  ) : _repository = repository,
      _loginUseCase = loginUseCase ?? LoginUseCase(repository),
      _logoutUseCase = logoutUseCase ?? LogoutUseCase(repository),
      _getCurrentUserUseCase =
          getCurrentUserUseCase ?? GetCurrentUserUseCase(repository) {
    _bootstrap();
  }

  final AuthRepository _repository;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthRepository get repository => _repository;

  AuthUser? _user;
  bool _isLoading = false;
  String? _error;

  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  Future<void> _bootstrap() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _getCurrentUserUseCase();
      _error = null;
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      final loggedUser = await _loginUseCase(
        usernameOrEmail: username,
        password: password,
      );
      _user = loggedUser;
      _error = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = AppException.unknown().message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
