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
  Future<bool> signIn(String email, String password) async {
    bool response = await authService.signIn(email, password);
    notifyListeners();
    return response;
  }

  // Sign in with google function
  Future<bool> signInWithGoogle() async {
    bool result = await authService.signInWithGoogle();
    notifyListeners();
    return result;
  }

  // Sign Up Function
  Future<UserCredential?> signUp(
      String email, String password, dynamic credentials) async {
    UserCredential? userCredential =
        await authService.signUp(email, password, credentials);
    notifyListeners();
    return userCredential;
  }

  // Sign up with google function
  Future<Map<String, dynamic>?> signUpWithGoogle() async {
    Map<String, dynamic>? credentials = await authService.signUpWithGoogle();
    notifyListeners();
    if (credentials != null) {
      return credentials;
    } else {
      return null;
    }
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
