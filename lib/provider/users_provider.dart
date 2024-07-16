import 'package:flutter/material.dart';
import 'package:tolentino_mini_project/api/firebase_userIds_api.dart';

class UserInfoProvider with ChangeNotifier {
  final UsersFriendsAPI userIds = UsersFriendsAPI();

  Future<void> saveUserInfo(String uid, Map<String, dynamic> userInfo) async {
    await userIds.saveUserInfo(uid, userInfo);
    notifyListeners();
  }

  Future<void> addFriend(String uid, String friendId) async {
    String message = await userIds.addFriend(uid, friendId);
    print(message);
    notifyListeners();
  }
}
