import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tolentino_exer7_firebase/api/friend_api.dart';
import 'package:tolentino_exer7_firebase/models/friend_model.dart';

// Provider class
class FriendListProvider with ChangeNotifier {
  late Stream<QuerySnapshot> _friendsStream;
  var firebaseService = FirebaseFriendsAPI();

  // Fetching friend list from the Firebase
  FriendListProvider() {
    fetchFriendList();
  }

  // Getter
  Stream<QuerySnapshot> get friendList => _friendsStream;

  // Accessing the friendLists from the firebase
  void fetchFriendList() {
    _friendsStream = firebaseService.getAllfriends();
    notifyListeners();
  }

  // Adding a friend and storing it in the firebase
  void addFriend(Friend friend) async {
    firebaseService.addFriend(friend.toJson(friend)).then((message) {
      print(message);
    });
    notifyListeners();
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

  // Delete a friendand update it in Firestore
  void deleteFriend(Friend friend) {
    firebaseService.deleteFriend(friend.id!).then((message) {
      print(message);
    });
    notifyListeners();
  }
}
