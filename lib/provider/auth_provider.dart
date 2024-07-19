import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tolentino_mini_project/api/firebase_auth_api.dart';

// Authentication provider
class UserAuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late Stream<User?> userStream;
  User? user;

  // Initializing the firebase, userstream, and the current user
  UserAuthProvider() {
    authService = FirebaseAuthAPI();
    userStream = authService.getUserStream();
    user = authService.getUser();
  }

  void fetchUserStream() {
    userStream = authService.getUserStream();
    notifyListeners();
  }

  String? getUserId() {
    String? userId = authService.getCurrentUserId();
    return userId;
  }

  // Sign in Function
  Future<String> signIn(String email, String password) async {
    String response = await authService.signIn(email, password);
    notifyListeners();
    return response;
  }

  // Sign Up Function
  Future<UserCredential?> signUp(String email, String password) async {
    UserCredential? userCredential = await authService.signUp(email, password);
    print(userCredential);
    notifyListeners();
    return userCredential;
  }

  // Sign out Function
  Future<void> signOut() async {
    await authService.signOut();
    user = null;
    notifyListeners();
  }

// Returns current user Id
  String? getCurrentUserId() {
    return authService.getCurrentUserId();
  }
}
