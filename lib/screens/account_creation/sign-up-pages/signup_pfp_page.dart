import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tolentino_mini_project/android_features/camera_feat.dart';
import 'package:tolentino_mini_project/screens/account_creation/sign-up-pages/signup_info_page.dart';

// Sign un page for adding profile picture
class SignupPfpPage extends StatefulWidget {
  // Variables
  final String? email;
  final String? password;

  // Constructor
  const SignupPfpPage({
    super.key,
    required this.email,
    required this.password,
  });
  @override
  _SignupPfpPageState createState() => _SignupPfpPageState();
}

class _SignupPfpPageState extends State<SignupPfpPage> {
  // Initializing camera feature
  final CameraFeature _cameraFeature = CameraFeature();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    // Asking users permission
    _cameraFeature.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Show image if it is not null
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.all(30),
              child: ClipRect(
                child: Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ),
          // Shows a button of adding profile photo and next
          Column(
            children: [
              ElevatedButton(
                // Shows the photo options
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

// Function for showing photo options
  void _photoOptions(BuildContext context) {
    // Shows a bottom modal sheet
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Take a picture
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
            // Choose from gallery
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
