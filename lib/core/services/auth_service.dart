import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseService _firebaseService = FirebaseService();

  /// Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      print('🔐 SignUp attempt: email=$email, password=${password.length} chars');
      final credential = await _firebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(fullName);

      print('✅ SignUp success: user_id=${credential.user?.uid}');

      // Create user profile in Firestore
      if (credential.user != null) {
        await _createUserProfile(
          userId: credential.user!.uid,
          email: email,
          fullName: fullName,
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      print('❌ SignUp failed: ${e.message} (code: ${e.code})');
      throw Exception('Đăng ký thất bại: ${_getVietnameseMessage(e.code)}');
    } catch (e) {
      print('❌ SignUp error: $e');
      throw Exception('Lỗi đăng ký: $e');
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 SignIn attempt: email=$email');
      final credential = await _firebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ SignIn success: user_id=${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('❌ SignIn failed: ${e.message} (code: ${e.code})');
      throw Exception('Đăng nhập thất bại: ${_getVietnameseMessage(e.code)}');
    } catch (e) {
      print('❌ SignIn error: $e');
      throw Exception('Lỗi đăng nhập: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseService.auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception('Sign out failed: ${e.message}');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseService.auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Reset password failed: ${e.message}');
    }
  }

  /// Create user profile in Firestore
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
  }) async {
    try {
      print('📝 Creating user profile: userId=$userId, email=$email');

      await _firebaseService.firestore.collection('users').doc(userId).set({
        'user_id': userId,
        'email': email,
        'fullname': fullName,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ User profile created');

      // Create default settings
      await _firebaseService.firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('user_settings')
          .set({
        'user_id': userId,
        'dark_mode': false,
        'notifications': true,
        'language': 'vi',
        'schedule_reminder_minutes': 15,
        'exam_reminder_minutes': 60,
        'enable_schedule_notifications': true,
        'enable_exam_notifications': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('✅ User settings created');
    } catch (e) {
      print('❌ Error creating user profile: $e');
      rethrow;
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _firebaseService.currentUser;
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _firebaseService.currentUserId;
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _firebaseService.isAuthenticated;
  }

  /// Get auth state changes stream
  Stream<User?> getAuthStateChanges() {
    return _firebaseService.authStateChanges;
  }

  /// Convert Firebase error codes to Vietnamese messages
  String _getVietnameseMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email này đã được sử dụng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'wrong-password':
        return 'Mật khẩu không đúng';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng';
      default:
        return code;
    }
  }
}
