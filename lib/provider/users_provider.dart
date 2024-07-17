import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tolentino_mini_project/api/firebase_userIds_api.dart';

// User information provider
class UserInfoProvider with ChangeNotifier {
  final UsersInfoAPI usersInfoAPI = UsersInfoAPI();
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userInfoStream;

  // Constructor to initialize and fetch user info
  UserInfoProvider() {
    getUserInfo();
  }

  // Getter for user info stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> get userInfoStream =>
      _userInfoStream;

  // Function to fetch user info
  void getUserInfo() {
    _userInfoStream = usersInfoAPI.getUserInfo();
    notifyListeners();
  }

  // Function to save user info
  Future<void> saveUserInfo(String uid, Map<String, dynamic> userInfo) async {
    await usersInfoAPI.saveUserInfo(uid, userInfo);
    notifyListeners();
  }

  // Function to add friend
  Future<void> addFriend(String uid, String friendId) async {
    await usersInfoAPI.addFriend(uid, friendId);
    notifyListeners();
  }
}
