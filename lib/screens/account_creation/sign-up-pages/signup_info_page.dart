import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/provider/auth_provider.dart';
import 'package:tolentino_mini_project/provider/friends_provider.dart';
import 'package:tolentino_mini_project/provider/storage_provider.dart';
import 'package:tolentino_mini_project/provider/users_provider.dart';
import 'package:tolentino_mini_project/screens/pages/friend_page.dart';

// Sign un page for additional informations
class SignupInfoPage extends StatefulWidget {
  // Variables
  final String? email;
  final String? password;
  final File? imageFile;

  // Constructor
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
  // Controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final List<TextEditingController> contactNumberControllers = [];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Dispossing the controllers
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
                // Text Fields
                children: [
                  textFieldCreator(usernameController, "Username"),
                  textFieldCreator(nameController, "Name"),
                  textFieldCreator(contactController, "Primary Contact Number"),
                  ...contactNumberControllers.map(
                    (controller) => textFieldCreator(
                        controller, "Additional Contact Number"),
                  ),
                  const SizedBox(height: 10),
                  // Button for adding contact numbers
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        contactNumberControllers.add(TextEditingController());
                      });
                    },
                    child: const Text("Add Contact Number"),
                  ),
                  const SizedBox(height: 20),
                  // Submit button
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

  // Function for creating text form fields
  Padding textFieldCreator(TextEditingController controller, String labelText) {
    switch (labelText) {
      case "Additional Contact Number":
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: TextFormField(
            controller: controller,
            validator: (val) {
              if (int.tryParse(val!) == null) {
                return "Enter a valid phone number";
              }
              return null;
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: labelText,
            ),
          ),
        );
      case "Primary Contact Number":
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: TextFormField(
            controller: controller,
            validator: (val) {
              if (val == null || val.isEmpty) {
                if (int.tryParse(val!) == null) {
                  return "Enter a valid phone number";
                } else {
                  "This is a required field";
                }
              }
              return null;
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: labelText,
            ),
          ),
        );
      default:
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
  }

  // Submit form
  submitForm(BuildContext context) async {
    final userInfo = {
      'email': widget.email,
      'username': usernameController.text,
      'name': nameController.text,
      'contact': contactController.text,
      'additional_contacts': contactNumberControllers
          .map((controller) => controller.text)
          .toList(),
      'friends': [],
    };

    // Access the uid of user upon creation
    String? uid = await getUid(widget.email!, widget.password!);

    if (uid != null) {
      try {
        // Upload the imageFile in the storage cloud
        if (widget.imageFile != null) {
          String? downloadURL = await context
              .read<StorageProvider>()
              .uploadProfilePicture(uid, widget.imageFile!);
          userInfo["profile-picture"] = downloadURL!;
        }

        // Save users info on the fire store
        await context.read<UserInfoProvider>().saveUserInfo(uid, userInfo);
        // Navigate to HomePage after signing up
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

  // Function for accessing UID
  Future<String?> getUid(String email, String password) async {
    try {
      // Stores the UID after signing up
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
