import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/formatting/formatting.dart';
import 'package:tolentino_mini_project/models/users-info_model.dart';
import 'package:tolentino_mini_project/provider/auth_provider.dart';
import 'package:tolentino_mini_project/provider/image-storage_provider.dart';
import 'package:tolentino_mini_project/provider/user-info_provider.dart';
import 'package:tolentino_mini_project/screens/pages/main_pages/friend_page.dart';

class SignupInfoPage extends StatefulWidget {
  // Variables
  final String? name;
  final String? email;
  final String? password;
  final File? imageFile;

  // Constructor
  const SignupInfoPage(
      {super.key,
      required this.name,
      required this.email,
      required this.password,
      required this.imageFile});

  @override
  State<SignupInfoPage> createState() => _SignupInfoPageState();
}

class _SignupInfoPageState extends State<SignupInfoPage> {
  // Controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final List<TextEditingController> contactNumberControllers = [];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Disposing controllers
    usernameController.dispose();
    contactController.dispose();
    for (var controller in contactNumberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Theme
      data: theme(),
      child: Scaffold(
        // Scaffold formatting
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: buildContent,
      ),
    );
  }

  // Main Content
  Widget get buildContent => SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 48, horizontal: 48),
            child: Column(
              children: [
                const SizedBox(height: 80),
                heading,
                Form(
                  key: formKey,
                  child: Column(
                    // Text fields
                    children: [
                      textFieldCreator(usernameController, "Username"),
                      textFieldCreator(
                          contactController, "Primary Contact Number"),
                      // Text Field creator for additional contact numbers
                      ...List.generate(contactNumberControllers.length,
                          (index) => displayAdditionalContact(index)),
                      contactButton,
                      const SizedBox(height: 20),
                      submitButton
                    ],
                  ),
                ),
              ],
            )),
      );

  // Heading text
  Widget get heading => Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
          "Almost there...",
          style: Formatting.semiBoldStyle.copyWith(fontSize: 32),
        ),
        Text(
          textAlign: TextAlign.center,
          "Onti nalang! Just complete your details to join and start connecting with friends!",
          style: Formatting.regularStyle.copyWith(
            fontSize: 14,
          ),
        )
      ]));

  // Add contact button
  Widget get contactButton => Row(children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 237, 237, 237),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(1),
            elevation: 1,
          ),
          // Adds contact controller
          onPressed: () {
            setState(() {
              contactNumberControllers.add(TextEditingController());
            });
          },
          child: const Icon(
            Icons.add,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        const SizedBox(width: 1),
        const Text(
          'Contact Number',
          style: TextStyle(fontSize: 16),
        ),
      ]);

  // Text field creator
  Padding textFieldCreator(TextEditingController controller, String labelText,
      {int? index}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: (val) {
          // Validators
          if (labelText == "Username") {
            if (val == null || val.isEmpty || val.trim().isEmpty) {
              return "This is a required field";
            }
          } else if (labelText == "Primary Contact Number") {
            if (val == null || val.isEmpty) {
              return "This is a required field";
            }
            if (int.tryParse(val) == null) {
              return "Enter a valid phone number";
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
  }

  // Displaying additional contacts
  Widget displayAdditionalContact(int index) {
    return Row(
      children: [
        Expanded(
          child: textFieldCreator(
            contactNumberControllers[index],
            "Additional Contact Number",
            index: index,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              contactNumberControllers.removeAt(index);
            });
          },
        ),
      ],
    );
  }

  // Submit button
  Widget get submitButton => SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        // Show button if enabled
        onPressed: () {
          // When validated, submit the form
          if (formKey.currentState!.validate()) {
            submitForm(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Formatting.primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
        ),
        child: Text(
          'Confirm',
          style: Formatting.mediumStyle.copyWith(
              fontSize: 16, color: const Color.fromRGBO(255, 255, 255, 1)),
        ),
      ));

  // Submitting the form
  void submitForm(BuildContext context) async {
    // Getting user's uid
    String? uid = await getUid(widget.email!, widget.password!);
    if (uid != null) {
      try {
        String? downloadURL;
        // Upload profile picture to the cloud
        if (widget.imageFile != null) {
          downloadURL = await context
              .read<StorageProvider>()
              .uploadProfilePicture(uid, widget.imageFile!);
        }
        // Creates userinfo and append it to the cloud
        UsersInfo temp = UsersInfo(
            name: widget.name!,
            username: usernameController.text,
            contact: contactController.text,
            profilePicURL: widget.imageFile == null ? null : downloadURL,
            additionalContacts: contactNumberControllers
                .map((controller) => controller.text)
                .toList());
        await context.read<UserInfoProvider>().saveUserInfo(uid, temp.toJson());
        // Proceed to the friends page
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

  // Function for getting users uid
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

// Themes
  ThemeData theme() {
    return ThemeData(
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: Formatting.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}
