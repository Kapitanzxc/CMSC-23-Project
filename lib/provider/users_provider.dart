import 'package:flutter/material.dart';
import 'package:tolentino_mini_project/api/firebase_userIds_api.dart';

// User information provider
class UserInfoProvider with ChangeNotifier {
  final UsersInfoAPI userIds = UsersInfoAPI();

  // Saves user info into the firestore
  Future<void> saveUserInfo(String uid, Map<String, dynamic> userInfo) async {
    await userIds.saveUserInfo(uid, userInfo);
    notifyListeners();
  }

  // Add friends ID to the user's friends array
  Future<void> addFriend(String uid, String friendId) async {
    String message = await userIds.addFriend(uid, friendId);
    print(message);
    notifyListeners();
  }
}
