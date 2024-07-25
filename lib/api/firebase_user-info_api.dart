import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tolentino_mini_project/api/firebase_auth_api.dart';

// API for userIds (users_provider)
class UsersInfoAPI {
  final FirebaseFirestore userIds = FirebaseFirestore.instance;
  final FirebaseAuthAPI authAPI = FirebaseAuthAPI();

  // Userid Collection Field
  Stream<DocumentSnapshot<Map<String, dynamic>>>? getUserInfo() {
    // Accessing current user id
    String? userId = authAPI.getCurrentUserId();
    if (userId != null) {
      //Snapshots
      return userIds.collection("userIds").doc(userId).snapshots();
    } else {
      print("Users Info: User ID not found.");
      return null;
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

  // Edit user's information
  Future<String> editUserInfo(String username, String contact,
      List<String> additionalContacts, String? profilePictureUrl) async {
    try {
      // Accessing current user id
      String? userId = authAPI.getCurrentUserId();
      await userIds.collection("userIds").doc(userId).update({
        "username": username,
        "contact": contact,
        "additionalContacts": additionalContacts,
        "profilePicURL": profilePictureUrl,
      });
      return "Successfully edited user's personal information";
    } on FirebaseException catch (e) {
      return "Failed with error: ${e.code}";
    }
  }

  // Fetch all emails
  Future<List<String>> getAllEmailsFromFirestore() async {
    try {
      // Fetch all documents from the userIds collection
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await userIds.collection('userIds').get();

      // Check if snapshot contains any docs
      if (snapshot.docs.isEmpty) {
        print("No documents found in the userIds collection.");
        return [];
      }

      // Extract emails from each document
      List<String> emails = snapshot.docs.map((doc) {
        final email = doc.data()['email'];
        // Return email if it's a valid string
        return email is String ? email : '';
      }).toList();

      print(emails);
      return emails;
    } catch (e) {
      print("Error fetching emails: $e");
      return [];
    }
  }

  // Fetch all usernames
  Future<List<String>> getAllUsernamesFromFirestore() async {
    try {
      // Fetch all documents from the userIds collection
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await userIds.collection('userIds').get();

      // Check if snapshot contains any docs
      if (snapshot.docs.isEmpty) {
        print("No documents found in the userIds collection.");
        return [];
      }

      // Extract emails from each document
      List<String> usernames = snapshot.docs.map((doc) {
        final username = doc.data()['username'];
        // Return email if it's a valid string
        return username is String ? username : '';
      }).toList();

      print(usernames);
      return usernames;
    } catch (e) {
      print("Error fetching emails: $e");
      return [];
    }
  }

  // Fetch all usernames and emails attached to it
  Future<List<Map<String, dynamic>>> getUsernameAndEmail() async {
    try {
      // Fetch all documents from the userIds collection
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('userIds').get();

      // Check if snapshot contains any docs
      if (snapshot.docs.isEmpty) {
        print("No documents found in the userIds collection.");
        return [];
      }

      // Extract usernames and emails from each document
      List<Map<String, dynamic>> usernamesAndEmails = snapshot.docs.map((doc) {
        final data = doc.data();
        final username = data['username'] ?? '';
        final email = data['email'] ?? '';
        return {'username': username, 'email': email};
      }).toList();

      print(usernamesAndEmails);
      return usernamesAndEmails;
    } catch (e) {
      print("Error fetching usernames and emails: $e");
      return [];
    }
  }
}
