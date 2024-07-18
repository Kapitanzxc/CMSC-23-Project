import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tolentino_mini_project/api/firebase_auth_api.dart';

// API for userIds (users_provider)
class UsersInfoAPI {
  final FirebaseFirestore userIds = FirebaseFirestore.instance;
  final FirebaseAuthAPI authAPI = FirebaseAuthAPI();

  // Userid Collection Field
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserInfo() {
    // Accessing current user id
    String? userId = authAPI.getCurrentUserId();
    if (userId != null) {
      //Snapshots
      return userIds.collection("userIds").doc(userId).snapshots();
    } else {
      throw Exception("User ID not found.");
    }
  }

  // Saves user info to the firebase
  Future<void> saveUserInfo(String uid, Map<String, dynamic> userInfo) async {
    await userIds.collection('userIds').doc(uid).set(userInfo);
    print("Successfully save user info");
  }

  // Adding a friend in the users id friend list
  Future<String> addFriend(String uid, String friendId) async {
    try {
      // Append the new friend docu id to the array
      await FirebaseFirestore.instance.collection("userIds").doc(uid).update({
        "friends": FieldValue.arrayUnion([friendId])
      });
      return "Successfully added friend to the user's friend list!";
    } on FirebaseException catch (e) {
      return "Failed with error: ${e.code}";
    }
  }

  // Edit user's information
  Future<String> editUserInfo(String username, String contact,
      List<String> additionalContacts, String profilePictureUrl) async {
    try {
      // Accessing current user id
      String? userId = authAPI.getCurrentUserId();
      await userIds.collection("userIds").doc(userId).update({
        "username": username,
        "contact": contact,
        "additionalContacts": additionalContacts,
        "profilePicURL": profilePictureUrl,
      });
      return "Successfully edited user's personal information";
    } on FirebaseException catch (e) {
      return "Failed with error: ${e.code}";
    }
  }
}
