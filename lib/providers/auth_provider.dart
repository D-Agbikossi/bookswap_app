import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  User? firebaseUser;
  AppUser? userProfile;
  bool loading = true;

  AuthProvider() {
    _service.firebaseUserChanges.listen((u) async {
      firebaseUser = u;
      if (u != null) {
        userProfile = await _service.fetchAppUser(u.uid);
      } else {
        userProfile = null;
      }
      loading = false;
      notifyListeners();
    });
  }

  bool get isSignedIn => firebaseUser != null;

  Future<void> signUp(String email, String password, String name) async {
    await _service.signUp(email, password, name);
  }

  Future<void> signIn(String email, String password) async {
    await _service.signIn(email, password);
  }

  Future<void> signOut() async {
    await _service.signOut();
  }

  Future<void> sendEmailVerification() => _service.sendEmailVerification();

  Future<void> refreshUserProfile() async {
    if (firebaseUser != null) {
      userProfile = await _service.fetchAppUser(firebaseUser!.uid);
      notifyListeners();
    }
  }
}
