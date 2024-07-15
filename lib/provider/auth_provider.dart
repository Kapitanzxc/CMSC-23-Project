import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tolentino_mini_project/api/firebase_auth_api.dart';

class UserAuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late Stream<User?> userStream;
  User? user;

  UserAuthProvider() {
    authService = FirebaseAuthAPI();
    userStream = authService.getUserStream();
  }

  Future<String> signIn(String email, String password) async {
    String response = await authService.signIn(email, password);
    notifyListeners();
    return response;
  }

  Future<String> signUp(String email, String password) async {
    String response = await authService.signUp(email, password);
    notifyListeners();
    return response;
  }

  Future<void> signOut() async {
    await authService.signOut();
    notifyListeners();
  }
}
