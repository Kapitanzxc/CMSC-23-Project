import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

// Storage API for images
class StorageAPI {
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Uploads the image to Firebase Storage and returns the download URL
  Future<String?> uploadImage(String userId, File? imageFile) async {
    if (imageFile == null) {
      print("Error: Image file is null.");
      return null;
    }

    try {
      // File name
      String fileName = imageFile.path.split('/').last;
      // Creates a reference in the Firebase
      Reference userFolderRef = storage.ref().child('profile_pics/$userId');
      // List all files in the user's folder
      ListResult result = await userFolderRef.listAll();

      if (result.items.length != 0) {
        // Delete all files in the user's folder
        for (Reference imageFiles in result.items) {
          await imageFiles.delete();
          print("Deleted existing image");
        }
      }

      // Creates a new reference for the new image
      Reference storageRef = userFolderRef.child(fileName);
      // Uploading the new image
      await storageRef.putFile(imageFile);
      // Accessing URL of the new image
      String downloadUrl = await storageRef.getDownloadURL();
      print("Successfully uploaded image");
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Uploads the friend's image to Firebase Storage and returns the download URL
  Future<String?> uploadFriendImage(
      String userId, String name, File? imageFile) async {
    if (imageFile == null) {
      print("Error: Image file is null.");
      return null;
    }

    try {
      // File name
      String fileName = imageFile.path.split('/').last;
      // Creates a reference in the Firebase
      Reference userFolderRef =
          storage.ref().child('profile_pics/$userId/friends/$name');
      // List all files in the user's folder
      ListResult result = await userFolderRef.listAll();

      if (result.items.length != 0) {
        // Delete all files in the user's folder
        for (Reference imageFiles in result.items) {
          await imageFiles.delete();
          print("Deleted existing image");
        }
      }

      // Creates a new reference for the new image
      Reference storageRef = userFolderRef.child(fileName);
      // Uploading the new image
      await storageRef.putFile(imageFile);
      // Accessing URL of the new image
      String downloadUrl = await storageRef.getDownloadURL();
      print("Successfully uploaded image in the user's friend list");
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}
