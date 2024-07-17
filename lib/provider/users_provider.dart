// User information provider
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tolentino_mini_project/api/firebase_userInfo_api.dart';
import 'package:tolentino_mini_project/models/user_model.dart';

class UserInfoProvider with ChangeNotifier {
  final UsersInfoAPI usersInfoAPI = UsersInfoAPI();
  late Stream<QuerySnapshot> _slambookData;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userInfoStream;

  // Constructor to initialize and fetch user info
  UserInfoProvider() {
    getUserInfo();
    fetchSlambookData();
  }

  // Getter for user info stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> get userInfoStream =>
      _userInfoStream;

  // Getter for user slambook stream
  Stream<QuerySnapshot<Object?>> get slambookData => _slambookData;

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

  // User ID Collection -> Slambook Collection

  // Accessing the friendLists from the firebase
  void fetchSlambookData() {
    _slambookData = usersInfoAPI.getSlambookData();
    print("Succesfully fetch slambook data");
    notifyListeners();
  }

  // Adding a friend and storing it in the firebase
  Future<void> addSlambookData(User user) async {
    try {
      await usersInfoAPI.addSlambookData(user.toJson(user));
      notifyListeners();
      print("Succesfully added slambook data to user's collection!");
    } catch (e) {
      print("Error adding friend: $e");
      return null;
    }
  }
}
