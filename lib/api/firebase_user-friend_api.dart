import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tolentino_mini_project/api/firebase_auth_api.dart';

// Firebase Class
class FirebaseFriendsAPI {
  final FirebaseFirestore friendList = FirebaseFirestore.instance;
  // Instantiate FirebaseAuthAPI
  final FirebaseAuthAPI authAPI = FirebaseAuthAPI();

  // Accessing friendlist from the firebase
  Stream<QuerySnapshot> getAllFriends() {
    // Accessing current user id
    String? userId = authAPI.getCurrentUserId();
    if (userId != null) {
      //Snapshots
      return friendList
          .collection("userIds")
          .doc(userId)
          .collection("friends")
          .snapshots();
    } else {
      throw Exception("User ID not found.");
    }
  }

  // Adding a friend in the firestore
  Future<void> addFriend(Map<String, dynamic> friend) async {
    String? userId = authAPI.getCurrentUserId(); // Get current user's ID
    if (userId != null) {
      try {
        await friendList
            .collection("userIds")
            .doc(userId)
            .collection("friends")
            .add(friend);
        print("Successfully added friend to user's friend list");
      } on FirebaseException catch (e) {
        print("Failed with error: ${e.code}");
      }
    } else {
      throw Exception("User not authenticated or user ID not found.");
    }
  }

  // Editing a friend in the firestore
  Future<String> editFriend(
      String id,
      String newNickname,
      String newAge,
      String newRelationshipStatus,
      String newHappinessLevel,
      String newSuperPower,
      String newMotto) async {
    try {
      await friendList.collection("userIds").doc(id).update({
        "nickname": newNickname,
        "age": newAge,
        "relationshipStatus": newRelationshipStatus,
        "happinessLevel": newHappinessLevel.toString(),
        "superpower": newSuperPower,
        "motto": newMotto,
      });
      return "Successfully edited a friend from user's friend list!";
    } on FirebaseException catch (e) {
      return "Failed with error: ${e.code}";
    }
  }

  // Deleting a friend in the firestore
  Future<String> deleteFriend(String id) async {
    try {
      String? userId = authAPI.getCurrentUserId(); // Get current user's ID
      await friendList
          .collection("userIds")
          .doc(userId)
          .collection("friends")
          .doc(id)
          .delete();
      return "Successfully removed friend from user's friend list!";
    } on FirebaseException catch (e) {
      return "Failed with error: ${e.code}";
    }
  }
}
