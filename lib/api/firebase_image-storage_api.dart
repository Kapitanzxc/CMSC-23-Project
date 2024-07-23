import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// Storage API for images
class StorageAPI {
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Uploads the image to Firebase Storage and returns the download URL
  Future<String?> uploadImage(String userId, dynamic image) async {
    if (image == null) {
      print("Error: Image file is null.");
      return null;
    }

    File? imageFile;
    // Check if the image is a URL
    if (image is String) {
      // Converting a string url to a file type
      final http.Response responseData = await http.get(Uri.parse(image));
      Uint8List uint8list = responseData.bodyBytes;
      var buffer = uint8list.buffer;
      ByteData byteData = ByteData.view(buffer);
      var tempDir = await getTemporaryDirectory();
      imageFile = await File('${tempDir.path}/img').writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }

    try {
      // File name
      String fileName = imageFile!.path.split('/').last;
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
