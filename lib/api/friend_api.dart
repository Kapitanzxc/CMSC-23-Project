import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase Class
class FirebaseFriendsAPI {
  final FirebaseFirestore friendList = FirebaseFirestore.instance;

  // Accessing friendlist from the firebase
  Stream<QuerySnapshot> getAllfriends() {
    return friendList.collection("friendLists").snapshots();
  }

  // Adding a friend in the firestore
  Future<String> addFriend(Map<String, dynamic> friend) async {
    try {
      await friendList.collection("friendLists").add(friend);
      return "Successfully added friend!";
    } on FirebaseException catch (e) {
      return "Failed with error: ${e.code}";
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
      await FirebaseFirestore.instance
          .collection("friendLists")
          .doc(id)
          .update({
        "nickname": newNickname,
        "age": newAge,
        "relationshipStatus": newRelationshipStatus,
        "happinessLevel": newHappinessLevel.toString(),
        "superpower": newSuperPower,
        "motto": newMotto,
      });
      return "Successfully edited a friend!";
    } on FirebaseException catch (e) {
      return "Failed with error: ${e.code}";
    }
  }

  // Deleting a friend in the firestore
  Future<String> deleteFriend(String id) async {
    try {
      await friendList.collection("friendLists").doc(id).delete();
      return "Successfully removed friend!";
    } on FirebaseException catch (e) {
      return "Failed with error: ${e.code}";
    }
  }
}
