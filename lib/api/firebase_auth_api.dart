import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthAPI {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Stream<User?> getUserStream() {
    return auth.authStateChanges(); // Returns a stream of user changes
  }

  User? getUser() {
    return auth.currentUser; // Returns who is logged in
  }

  Future<String> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return "Successfully signed in!";
    } on FirebaseAuthException catch(e) {
      return "Failed at error: ${e.code}";
    }
  }

  Future<String> signUp(String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(email: email, password: password);
      return "Successfully created account!";
    } on FirebaseAuthException catch(e) {
      return "Failed at error: ${e.code}";
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}