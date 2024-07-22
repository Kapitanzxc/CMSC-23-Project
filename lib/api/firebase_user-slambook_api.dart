import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tolentino_mini_project/api/firebase_auth_api.dart';
import 'package:tolentino_mini_project/models/user-slambook_model.dart';

// API for userIds (users_provider)
class UserSlambook {
  final FirebaseFirestore usersFriendList = FirebaseFirestore.instance;
  final FirebaseAuthAPI authAPI = FirebaseAuthAPI();

  // Accessing user's slambook data from the firebase
  Stream<QuerySnapshot> getSlambookData() {
    // Accessing current user id
    String? userId = authAPI.getCurrentUserId();
    if (userId != null) {
      //Snapshots
      return usersFriendList
          .collection("userIds")
          .doc(userId)
          .collection("personal_slambook")
          .snapshots();
    } else {
      throw Exception("User ID not found.");
    }
  }

  // Adding a slambook data to the userid
  Future<void> addSlambookData(Map<String, dynamic> user) async {
    String? userId = authAPI.getCurrentUserId(); // Get current user's ID
    if (userId != null) {
      try {
        await usersFriendList
            .collection("userIds")
            .doc(userId)
            .collection("personal_slambook")
            .add(user);
        print("Succesfully added slambook data to user's collection!");
      } on FirebaseException catch (e) {
        print("Failed with error: ${e.code}");
      }
    } else {
      throw Exception("User not authenticated or user ID not found.");
    }
  }

  // Edit user's slambook
  Future<String> editUserSlambook(Users user) async {
    try {
      // Accessing current user id
      String? userId = authAPI.getCurrentUserId();
      await usersFriendList
          .collection("userIds")
          .doc(userId)
          .collection("personal_slambook")
          .doc(user.id)
          .update({
        "nickname": user.nickname,
        "age": user.age,
        "relationshipStatus": user.relationshipStatus,
        "happinessLevel": user.happinessLevel,
        "superpower": user.superpower,
        "motto": user.motto,
      });
      return "Successfully edited user's slambook";
    } on FirebaseException catch (e) {
      return "Failed with error: ${e.code}";
    }
  }

  // Edit user's profile picture
  Future<String> editUserPicture(String? downloadURL, Users user) async {
    try {
      // Accessing current user id
      String? userId = authAPI.getCurrentUserId();
      await usersFriendList
          .collection("userIds")
          .doc(userId)
          .collection("personal_slambook")
          .doc(user.id)
          .update({"profilePictureURL": downloadURL});
      return "Successfully edited user's profile picture";
    } on FirebaseException catch (e) {
      return "Failed with error: ${e.code}";
    }
  }
}
