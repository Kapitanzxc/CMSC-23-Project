import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tolentino_mini_project/api/firebase_storage_api.dart';

class StorageProvider with ChangeNotifier {
  final StorageAPI _storageAPI = StorageAPI();
  String? _profilePictureUrl;

  String? get profilePictureUrl => _profilePictureUrl;

  Future<String?> uploadProfilePicture(String userId, File? imageFile) async {
    if (imageFile == null) {
      print("No image file provided.");
      return null;
    }

    String? downloadUrl = await _storageAPI.uploadImage(userId, imageFile);
    if (downloadUrl != null) {
      notifyListeners();
      return downloadUrl;
    } else {
      return null;
    }
  }

  // Future<void> fetchProfilePicture(String userId) async {
  //   String? downloadUrl = await _storageAPI.getProfilePicture(userId);
  //   if (downloadUrl != null) {
  //     _profilePictureUrl = downloadUrl;
  //     notifyListeners();
  //   }
  // }
}
