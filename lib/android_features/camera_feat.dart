// camera_feature.dart

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraFeature {
  final Permission _permission = Permission.camera;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  Future<void> requestPermission() async {
    final status = await _permission.request();
    _permissionStatus = status;
  }

  Future<File?> takePicture() async {
    if (_permissionStatus == PermissionStatus.granted) {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      return image == null ? null : File(image.path);
    } else {
      await requestPermission();
      if (_permissionStatus == PermissionStatus.granted) {
        return takePicture();
      }
    }
    return null;
  }

  Future<File?> chooseFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    return image == null ? null : File(image.path);
  }
}
