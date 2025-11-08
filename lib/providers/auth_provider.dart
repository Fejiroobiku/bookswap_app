import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  AppUser? _user;
  bool _isLoading = false;

  AuthProvider(this._authService) {
    print('🔄 AuthProvider initialized');
    // Listen to auth state changes
    _authService.user.listen((user) {
      print('👤 Auth state changed: $user');
      _user = user;
      notifyListeners();
    });
  }

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  Future<bool> register(String email, String password, String displayName) async {
    _isLoading = true;
    notifyListeners();
    print('📝 Starting registration...');

    final error = await _authService.register(email, password, displayName);
    
    _isLoading = false;
    notifyListeners();
    
    if (error == null) {
      print('✅ Registration successful');
      return true;
    } else {
      print('❌ Registration failed: $error');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    print('🔐 Starting login...');

    final error = await _authService.login(email, password);
    
    _isLoading = false;
    notifyListeners();
    
    if (error == null) {
      print('✅ Login successful');
      return true;
    } else {
      print('❌ Login failed: $error');
      return false;
    }
  }

  Future<void> logout() async {
    print('🚪 Logging out...');
    await _authService.logout();
  }
}