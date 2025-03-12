import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localrental_flutter/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FitnessAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isLoading = false;
  String? error;
  User? _user;
  User? get user => _user;
  bool get isAuthenticated => _user != null;
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

  Future<bool> signUp(
      String email, String password, BuildContext context) async {
    setLoading(true);
    try {
      await _authService.createUserWithEmailAndPassword(email, password);
      error = null;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up successful!'),
            backgroundColor: Color(0xff92A3FD),
            duration: Duration(seconds: 2),
          ),
        );
      }
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

  // Add the missing autoLogin method
  Future<void> autoLogin() async {
    isLoading = true;
    notifyListeners();

    // Check if a user is already signed in
    try {
      // Get current user from Firebase Authentication
      final currentUser = _authService.currentUser;

      if (currentUser != null) {
        // User is already logged in
        _user = currentUser;

        // Store login info in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      } else {
        // Check if we have stored login info
        final prefs = await SharedPreferences.getInstance();
        final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

        if (isLoggedIn) {
          // Try to refresh user credentials
          // Note: This is just a flag check, the actual authentication state
          // is managed by Firebase. If the user's session has expired, they'll
          // need to log in again regardless of this flag.
          _user = _authService.currentUser;
        }
      }
    } catch (e) {
      // Handle any errors that might occur during auto-login
      print('Auto-login error: $e');
      _user = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
