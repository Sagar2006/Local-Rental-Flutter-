import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localrental_flutter/services/auth_service.dart';

class FitnessAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isLoading = false;
  String? error;

  User? get currentUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<bool> signIn(String email, String password) async {
    setLoading(true);
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      error = null;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

<<<<<<< HEAD
  Future<bool> signUp(String email, String password, BuildContext context) async {
=======
  Future<bool> signUp(String email, String password) async {
>>>>>>> 695ea4201ba1ae45ce934cdfedd50e1c631a7520
    setLoading(true);
    try {
      await _authService.createUserWithEmailAndPassword(email, password);
      error = null;
<<<<<<< HEAD
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up successful!'),
            backgroundColor: Color(0xff92A3FD),
            duration: Duration(seconds: 2),
          ),
        );
      }
=======
>>>>>>> 695ea4201ba1ae45ce934cdfedd50e1c631a7520
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
