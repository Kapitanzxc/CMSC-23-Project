import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      // Creates a reference in the firebase
      Reference storageRef =
          storage.ref().child('profile_pics/$userId/$fileName');
      // Uploading the image
      await storageRef.putFile(imageFile);
      // Accessing URL
      String downloadUrl = await storageRef.getDownloadURL();
      print("Successfully uploaded image");
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}
