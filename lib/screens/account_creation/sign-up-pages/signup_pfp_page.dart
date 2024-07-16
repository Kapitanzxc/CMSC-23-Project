import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tolentino_mini_project/android_features/camera_feat.dart';
import 'package:tolentino_mini_project/screens/account_creation/sign-up-pages/signup_info_page.dart';

class SignupPfpPage extends StatefulWidget {
  final String? email;
  final String? password;

  const SignupPfpPage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  _SignupPfpPageState createState() => _SignupPfpPageState();
}

class _SignupPfpPageState extends State<SignupPfpPage> {
  final CameraFeature _cameraFeature = CameraFeature();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _cameraFeature.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.all(30),
              child: ClipRect(
                child: Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () => _photoOptions(context),
                child: const Text('Add Profile Photo'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupInfoPage(
                        email: widget.email,
                        password: widget.password,
                        imageFile: _imageFile,
                      ),
                    ),
                  );
                },
                child: const Text('Next'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  void _photoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a picture'),
              onTap: () async {
                Navigator.of(context).pop();
                final image = await _cameraFeature.takePicture();
                setState(() {
                  _imageFile = image;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                final image = await _cameraFeature.chooseFromGallery();
                setState(() {
                  _imageFile = image;
                });
              },
            ),
          ],
        );
      },
    );
  }
}
