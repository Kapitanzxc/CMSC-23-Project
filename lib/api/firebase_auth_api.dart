import 'package:firebase_auth/firebase_auth.dart';

// Authentication API
class FirebaseAuthAPI {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Stream<User?> getUserStream() {
    return auth.authStateChanges(); // Returns a stream of user changes
  }

  User? getUser() {
    return auth.currentUser; // Returns who is logged in
  }

  String? getCurrentUserId() {
    return auth.currentUser?.uid; // Returns UID of the current user
  }

  // Function for signing in
  Future<bool> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      print("Successfully signed in!");
      return true;
    } on FirebaseAuthException catch (e) {
      print("Failed at error: ${e.code}");
      return false;
    }
  }

  // Function for signing up
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      UserCredential? userCredential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);
      print("Successfully created account!");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Failed at error: ${e.code}");
      return null;
    }
  }

  // Function for signing out
  Future<void> signOut() async {
    print("Successfully signed out!");
    await auth.signOut();
  }

  Future<bool> emailExists(String email) async {
    try {
      final methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
