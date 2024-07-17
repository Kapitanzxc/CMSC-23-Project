import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tolentino_mini_project/api/firebase_auth_api.dart';

// API for userIds (users_provider)
class UsersInfoAPI {
  final FirebaseFirestore userIds = FirebaseFirestore.instance;
  final FirebaseAuthAPI authAPI = FirebaseAuthAPI();

  // Userid Collection Field
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserInfo() {
    // Accessing current user id
    String? userId = authAPI.getCurrentUserId();
    if (userId != null) {
      //Snapshots
      return userIds.collection("userIds").doc(userId).snapshots();
    } else {
      throw Exception("User ID not found.");
    }
  }

  // Saves user info to the firebase
  Future<void> saveUserInfo(String uid, Map<String, dynamic> userInfo) async {
    await userIds.collection('userIds').doc(uid).set(userInfo);
    print("Successfully save user info");
  }

  // Adding a friend in the users id friend list
  Future<String> addFriend(String uid, String friendId) async {
    try {
      // Append the new friend docu id to the array
      await FirebaseFirestore.instance.collection("userIds").doc(uid).update({
        "friends": FieldValue.arrayUnion([friendId])
      });
      return "Successfully added friend to the user's friend list!";
    } on FirebaseException catch (e) {
      return "Failed with error: ${e.code}";
    }
  }

  // User ID Collection -> Slambook Collection

  // Accessing user's slambook data from the firebase
  Stream<QuerySnapshot> getSlambookData() {
    // Accessing current user id
    String? userId = authAPI.getCurrentUserId();
    if (userId != null) {
      //Snapshots
      return userIds
          .collection("userIds")
          .doc(userId)
          .collection("personal_slambook")
          .snapshots();
    } else {
      throw Exception("User ID not found.");
    }
  }

  // Adding a slambook data to the userid
  Future<void> addSlambookData(Map<String, dynamic> user) async {
    String? userId = authAPI.getCurrentUserId(); // Get current user's ID
    if (userId != null) {
      try {
        await userIds
            .collection("userIds")
            .doc(userId)
            .collection("personal_slambook")
            .add(user);
        print("Successfully added friend to Firestore");
      } on FirebaseException catch (e) {
        print("Failed with error: ${e.code}");
      }
    } else {
      throw Exception("User not authenticated or user ID not found.");
    }
  }
}
