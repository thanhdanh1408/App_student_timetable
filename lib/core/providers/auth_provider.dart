import 'package:flutter/material.dart';
import '/core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userId;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userId => _userId;

  /// Initialize auth state
  Future<void> initialize() async {
    try {
      final user = _authService.getCurrentUser();
      _isAuthenticated = user != null;
      _userEmail = user?.email;
      _userId = user?.uid;
      notifyListeners();

      // Listen to auth state changes
      _authService.getAuthStateChanges().listen((user) {
        _isAuthenticated = user != null;
        _userEmail = user?.email;
        _userId = user?.uid;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _authService.signIn(
        email: email,
        password: password,
      );
      _isAuthenticated = true;
      _userEmail = credential.user?.email;
      _userId = credential.user?.uid;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _isAuthenticated = false;
      _userEmail = null;
      _userId = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Convenience method for login (alias for signIn)
  Future<bool> login(String email, String password) async {
    return signIn(email: email, password: password);
  }

  /// Convenience method for register (alias for signUp)
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return signUp(email: email, password: password, fullName: fullName);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
