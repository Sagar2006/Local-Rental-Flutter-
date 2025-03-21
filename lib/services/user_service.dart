import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localrental_flutter/models/user_model.dart';

class UserService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      final snapshot = await _dbRef.child('users/$uid').get();

      if (snapshot.exists) {
        return UserModel.fromMap(
            Map<String, dynamic>.from(snapshot.value as Map));
      }

      // If no user data found, create one from Firebase Auth user
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser != null && authUser.uid == uid) {
        final newUser = UserModel.fromFirebaseUser(authUser);
        await saveUserData(newUser);
        return newUser;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Save user data
  Future<bool> saveUserData(UserModel user) async {
    try {
      await _dbRef.child('users/${user.uid}').set(user.toMap());
      return true;
    } catch (e) {
      print('Error saving user data: $e');
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String uid,
    String? displayName,
    String? phoneNumber,
    String? address,
    String? bio,
  }) async {
    try {
      final userData = await getUserData(uid);
      if (userData == null) return false;

      final updatedUser = userData.copyWith(
        displayName: displayName,
        phoneNumber: phoneNumber,
        address: address,
        bio: bio,
      );

      return await saveUserData(updatedUser);
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
}
