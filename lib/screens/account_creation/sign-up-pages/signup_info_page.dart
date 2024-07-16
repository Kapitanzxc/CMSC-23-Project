import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/models/friend_model.dart';
import 'package:tolentino_mini_project/provider/auth_provider.dart';
import 'package:tolentino_mini_project/provider/friends_provider.dart';
import 'package:tolentino_mini_project/provider/storage_provider.dart';
import 'package:tolentino_mini_project/provider/users_provider.dart';
import 'package:tolentino_mini_project/screens/pages/friend_page.dart';
import 'package:tolentino_mini_project/screens/pages/home_page.dart';

// Sign un page for additional informations
class SignupInfoPage extends StatefulWidget {
  final String? email;
  final String? password;
  final File? imageFile;

  const SignupInfoPage({
    super.key,
    required this.email,
    required this.password,
    this.imageFile,
  });

  @override
  _SignupInfoPageState createState() => _SignupInfoPageState();
}

class _SignupInfoPageState extends State<SignupInfoPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final List<TextEditingController> contactNumberControllers = [];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    contactController.dispose();
    for (var controller in contactNumberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 239, 230, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(26, 77, 46, 1),
        title: const Text(
          "Creating your Account",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Additional Information",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(79, 111, 82, 1),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: formKey,
              child: Column(
                children: [
                  textFieldCreator(usernameController, "Username"),
                  textFieldCreator(nameController, "Name"),
                  textFieldCreator(contactController, "Contact Number"),
                  ...contactNumberControllers.map(
                    (controller) => textFieldCreator(
                        controller, "Additional Contact Number"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        contactNumberControllers.add(TextEditingController());
                      });
                    },
                    child: const Text("Add Additional Contact Number"),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromRGBO(79, 111, 82, 1),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            submitForm(context);
                          }
                        },
                        icon: const Icon(Icons.send, size: 20),
                        label: const Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding textFieldCreator(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        validator: (val) {
          if (val == null || val.isEmpty || val.trim().isEmpty) {
            return "This is a required field";
          }
          return null;
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
        ),
      ),
    );
  }

  submitForm(BuildContext context) async {
    final userInfo = {
      'username': usernameController.text,
      'name': nameController.text,
      'contact': contactController.text,
      'additional_contacts': contactNumberControllers
          .map((controller) => controller.text)
          .toList(),
      'friends': [],
    };

    String? uid = await getUid(widget.email!, widget.password!);

    if (uid != null) {
      try {
        // Upload profile picture if provided
        if (widget.imageFile != null) {
          String? downloadURL = await context
              .read<StorageProvider>()
              .uploadProfilePicture(uid, widget.imageFile!);
          userInfo["profile-picture"] = downloadURL!;
        }

        // Save user info
        await context.read<UserInfoProvider>().saveUserInfo(uid, userInfo);
        context.read<FriendListProvider>().fetchFriendList();
        // Navigate to HomePage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FriendsPage()),
        );
      } catch (e) {
        print("Error saving user info: $e");
      }
    } else {
      print("Failed to get UID, user information not saved.");
    }
  }

  Future<String?> getUid(String email, String password) async {
    try {
      UserCredential? userCredential = await context
          .read<UserAuthProvider>()
          .authService
          .signUp(email, password);
      String uid = userCredential!.user!.uid;
      return uid;
    } catch (e) {
      print("Error signing up: $e");
      return null;
    }
  }
}
