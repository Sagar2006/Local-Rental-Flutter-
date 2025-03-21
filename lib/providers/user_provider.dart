import 'package:flutter/material.dart';
import 'package:localrental_flutter/models/user_model.dart';
import 'package:localrental_flutter/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  final UserService _userService = UserService();
  bool _isLoading = false;
  String _error = '';

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;

  UserProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _user = await _userService.getUserData(currentUser.uid);
      _error = '';
    } catch (e) {
      _error = 'Failed to load user data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? address,
    String? bio,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final success = await _userService.updateUserProfile(
        uid: currentUser.uid,
        displayName: displayName,
        phoneNumber: phoneNumber,
        address: address,
        bio: bio,
      );

      if (success) {
        // If update was successful, reload the user data
        await _loadCurrentUser();
        return true;
      } else {
        _error = 'Failed to update profile';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating profile: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
