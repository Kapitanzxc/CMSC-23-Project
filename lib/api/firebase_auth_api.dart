import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  Future<UserCredential?> signUp(
      String email, String password, dynamic credentials) async {
    try {
      UserCredential? userCredential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (credentials != null) linkEmailGoogle(credentials);
      print("Successfully created account!");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Failed at error: ${e.code}");
      return null;
    }
  }

  // Function for linkup email/password with google account
  void linkEmailGoogle(dynamic credentials) async {
    //now link these credentials with the existing user
    await auth.currentUser!.linkWithCredential(credentials);
  }

  // Function for signing out
  Future<void> signOut() async {
    print("Successfully signed out!");
    await auth.signOut();
  }

  Future<bool> signInWithGoogle(List<String?> emails) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return false;
      }

      // Authenticate user credentials
      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      // Access user's credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      if (emails.contains(googleUser.email)) {
        // Proceed with sign-in if user exists
        await FirebaseAuth.instance.signInWithCredential(credential);
        print('User exists in the database.');
        return true;
      } else {
        print('User does not exist in the database.');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: $e');
      return false;
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }

  // Function for signing up with google
  Future<Map<String, dynamic>?> signUpWithGoogle(List<String?> emails) async {
    try {
      // Google Sign-In UI
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-up
        return null;
      }

      // Extract email, name, and profile picture
      final email = googleUser.email;
      final displayName = googleUser.displayName;
      final profilePictureURL = googleUser.photoUrl;

      // Retrieves the authentication details
      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      // User's credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      if (emails.contains(googleUser.email)) {
        // If email exists already, return null:
        print('User already exists in the database.');
        return null;
      } else {
        print('User does not exist in the database.');
        // Return a map containing email,name, profile picture, and credentials
        return {
          'credentials': credential,
          'email': email,
          'name': displayName,
          'profilePictureURL': profilePictureURL,
        };
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: $e');
    } catch (e) {
      print('Exception: $e');
    }
    return null;
  }
}
