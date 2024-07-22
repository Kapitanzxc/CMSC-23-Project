// User information provider
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tolentino_mini_project/api/firebase_user-slambook_api.dart';
import 'package:tolentino_mini_project/models/user-slambook_model.dart';

class UserSlambookProvider with ChangeNotifier {
  final UserSlambook usersInfoAPI = UserSlambook();
  late Stream<QuerySnapshot> _slambookData;
  Users? _user;

  Users? get user => _user;

  // Constructor to initialize and fetch user info
  UserSlambookProvider() {
    fetchSlambookData();
  }

  // Getter for user slambook stream
  Stream<QuerySnapshot<Object?>> get slambookData => _slambookData;

  // Accessing the friendLists from the firebase
  void fetchSlambookData() {
    _slambookData = usersInfoAPI.getSlambookData();
    print("Succesfully fetch slambook data");
    notifyListeners();
  }

  // Adding a friend and storing it in the firebase
  Future<void> addSlambookData(Users user) async {
    try {
      await usersInfoAPI.addSlambookData(user.toJson(user));
      notifyListeners();
    } catch (e) {
      print("Error adding friend: $e");
      return null;
    }
  }

  // Edit user's slambook
  void editUserSlambook(
      Users user,
      String newNickname,
      String newAge,
      String newRelationshipStatus,
      String newHappinessLevel,
      String newSuperPower,
      String newMotto) {
    user.nickname = newNickname;
    user.age = newAge;
    user.relationshipStatus = newRelationshipStatus;
    user.happinessLevel = newHappinessLevel;
    user.superpower = newSuperPower;
    user.motto = newMotto;
    usersInfoAPI.editUserSlambook(user).then((message) {
      print(message);
    });
    notifyListeners();
  }

  // Edit user's profile picture
  Future<void> editUserPicture(String? downloadURL, Users user) async {
    try {
      usersInfoAPI.editUserPicture(downloadURL, user).then((message) {
        print(message);
        notifyListeners();
      });
    } on FirebaseException catch (e) {
      print("Failed with error: ${e.code}");
    }
  }

  void setUser(Users user) {
    _user = user;
    notifyListeners();
  }
}
