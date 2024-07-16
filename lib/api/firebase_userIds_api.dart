import 'package:cloud_firestore/cloud_firestore.dart';

class UsersFriendsAPI {
  final FirebaseFirestore userIds = FirebaseFirestore.instance;

  Future<void> saveUserInfo(String uid, Map<String, dynamic> userInfo) async {
    await userIds.collection('userIds').doc(uid).set(userInfo);
    print("Successfully save user info");
  }

  // Adding a friend in the users id friend list
  Future<String> addFriend(String uid, String friendId) async {
    try {
      print(uid);
      await FirebaseFirestore.instance.collection("userIds").doc(uid).update({
        "friends": FieldValue.arrayUnion([friendId])
      });
      return "Successfully added friend to the user's friend list!";
    } on FirebaseException catch (e) {
      return "Failed with error: ${e.code}";
    }
  }
}
