import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tolentino_mini_project/api/firebase_image-storage_api.dart';

// Storage provider that stores images on the cloud
class StorageProvider with ChangeNotifier {
  final StorageAPI _storageAPI = StorageAPI();
  String? _profilePictureUrl;

  // Getter
  String? get profilePictureUrl => _profilePictureUrl;

  // Uploads imagefile to the cloud
  Future<String?> uploadProfilePicture(String userId, File? imageFile) async {
    if (imageFile == null) {
      print("No image file provided.");
      return null;
    }
    // Return url after uploading
    String? downloadUrl = await _storageAPI.uploadImage(userId, imageFile);
    if (downloadUrl != null) {
      notifyListeners();
      return downloadUrl;
    } else {
      return null;
    }
  }
}
