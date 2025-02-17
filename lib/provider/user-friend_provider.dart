import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tolentino_mini_project/api/firebase_user-friend_api.dart';
import 'package:tolentino_mini_project/models/friend_model.dart';

// Friend Lists provider (UserIds -> Friends Collection)
class FriendListProvider with ChangeNotifier {
  late Stream<QuerySnapshot> _friendsStream;
  var firebaseService = FirebaseFriendsAPI();

  // Fetching friend list from the Firebase
  FriendListProvider() {
    fetchFriendList();
  }

  // Accessing the friendLists from the firebase
  void fetchFriendList() {
    _friendsStream = firebaseService.getAllFriends();
    notifyListeners();
  }

  // Getter
  Stream<QuerySnapshot> get friendList => _friendsStream;

  // Adding a friend and storing it in the firebase
  Future<void> addFriend(String userId, Friend friend) async {
    try {
      await firebaseService.addFriend(friend.toJson(friend));
      notifyListeners();
    } catch (e) {
      print("Error adding friend: $e");
    }
  }

  // Edit a friend and update it in Firestore
  void editFriend(
      Friend friend,
      String newNickname,
      String newAge,
      String newRelationshipStatus,
      String newHappinessLevel,
      String newSuperPower,
      String newMotto) {
    friend.nickname = newNickname;
    friend.age = newAge;
    friend.relationshipStatus = newRelationshipStatus;
    friend.happinessLevel = newHappinessLevel;
    friend.superpower = newSuperPower;
    friend.motto = newMotto;
    firebaseService
        .editFriend(friend.id!, newNickname, newAge, newRelationshipStatus,
            newHappinessLevel.toString(), newSuperPower, newMotto)
        .then((message) {
      print(message);
    });
    notifyListeners();
  }

// Function for editing friend profile picture
  Future<String> editFriendProfilePicture(
      Friend friend, String? profilePictureURL) async {
    try {
      firebaseService.editFriendProfilePicture(friend, profilePictureURL);
      return "Successfully edited a friend from user's friend list!";
    } on FirebaseException catch (e) {
      return "Failed with error: ${e.code}";
    }
  }

  // Delete a friendand update it in Firestore
  void deleteFriend(Friend friend) {
    firebaseService.deleteFriend(friend.id!).then((message) {
      print(message);
    });
    notifyListeners();
  }
}
