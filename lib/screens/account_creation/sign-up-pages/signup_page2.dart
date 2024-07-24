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
  final String? profilePictureURL;
  final OAuthCredential? credentials;

  // Constructor
  const SignupInfoPage(
      {super.key,
      required this.name,
      required this.email,
      required this.password,
      this.imageFile,
      this.profilePictureURL,
      this.credentials});

  @override
  State<SignupInfoPage> createState() => _SignupInfoPageState();
}

class _SignupInfoPageState extends State<SignupInfoPage> {
  // Controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final List<TextEditingController> contactNumberControllers = [];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // disable button
  bool isButtonEnabled = false;

  // Updates the button if fields are empty
  void _checkFields() {
    setState(() {
      if (usernameController.text.isNotEmpty &&
          contactController.text.isNotEmpty) {
        bool controllersChecker = true;
        for (var controller in contactNumberControllers) {
          if (controller.text.isEmpty) {
            controllersChecker = false;
          }
        }
        if (controllersChecker) isButtonEnabled = true;
      } else {
        isButtonEnabled = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Listeners to the controllers
    usernameController.addListener(_checkFields);
    contactController.addListener(_checkFields);
  }

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
          style: Formatting.semiBoldStyle
              .copyWith(fontSize: 32, color: Formatting.black),
        ),
        Text(
          textAlign: TextAlign.center,
          "Just a jump away! Complete your info to join and start hopping with pals!",
          style: Formatting.regularStyle
              .copyWith(fontSize: 14, color: Formatting.black),
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
              final controller = TextEditingController();
              controller.addListener(_checkFields);
              setState(() {
                contactNumberControllers.add(controller);
              });
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
          style: TextStyle(fontSize: 16, color: Formatting.black),
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
          } else if (labelText == "Primary Contact Number" ||
              labelText == "Additional Contact Number") {
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
        onPressed: isButtonEnabled
            ? () {
                if (formKey.currentState!.validate()) {
                  submitForm(context);
                }
              }
            : null,
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
    String? uid =
        await getUid(widget.email!, widget.password!, widget.credentials);
    if (uid != null) {
      try {
        String? downloadURL;
        // Upload profile picture to the cloud
        if (widget.imageFile != null) {
          downloadURL = await context
              .read<StorageProvider>()
              .uploadProfilePicture(uid, widget.imageFile!);
        } else if (widget.profilePictureURL != null) {
          downloadURL = await context
              .read<StorageProvider>()
              .uploadProfilePicture(uid, widget.profilePictureURL);
        }
        // Creates userinfo and append it to the cloud
        UsersInfo temp = UsersInfo(
            email: widget.email!,
            name: widget.name!,
            username: usernameController.text,
            contact: contactController.text,
            profilePicURL:
                (widget.imageFile != null || widget.profilePictureURL != null)
                    ? downloadURL
                    : null,
            additionalContacts: contactNumberControllers
                .map((controller) => controller.text)
                .toList());
        await context.read<UserInfoProvider>().saveUserInfo(uid, temp.toJson());
        showSignInDialog(context);
      } catch (e) {
        print("Error saving user info: $e");
      }
    } else {
      print("Failed to get UID, user information not saved.");
    }
  }

  // Function for getting users uid
  Future<String?> getUid(
      String email, String password, dynamic credentials) async {
    try {
      UserCredential? userCredential = await context
          .read<UserAuthProvider>()
          .authService
          .signUp(email, password, credentials);
      String uid = userCredential!.user!.uid;
      return uid;
    } catch (e) {
      print("Error signing up: $e");
      if (mounted) {
        // Check if the widget is still mounted
        showSignInErrorDialog(context);
      }
      return null;
    }
  }

  // Show error dialog
  void showSignInErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                // Image
                Container(
                  width: 150,
                  height: 150,
                  child: Image.asset("assets/frog_sad.png"),
                ),
                const SizedBox(height: 10),
                // Text
                Text(
                  "Oops something went wrong!",
                  style: Formatting.boldStyle
                      .copyWith(fontSize: 24, color: Formatting.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Text
                Text(
                  "This email is already in use. Please log in or use a different email.",
                  style: Formatting.mediumStyle
                      .copyWith(fontSize: 12, color: Formatting.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // Try again button
            SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Formatting.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Try Again',
                    style: Formatting.mediumStyle.copyWith(
                        fontSize: 16,
                        color: const Color.fromRGBO(255, 255, 255, 1)),
                  ),
                )),
          ],
        );
      },
    );
  }

  // Show error dialog
  void showSignInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                // Image
                Container(
                  width: 150,
                  height: 150,
                  child: Image.asset("assets/frog_happy.png"),
                ),
                const SizedBox(height: 10),
                // Text
                Text(
                  "Ribbit! You're In!",
                  style: Formatting.boldStyle
                      .copyWith(fontSize: 24, color: Formatting.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Text
                Text(
                  "You’ve hopped right in. Start making friends and filling your slambook!",
                  style: Formatting.mediumStyle
                      .copyWith(fontSize: 12, color: Formatting.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // Jump in button
            SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  // Show button if enabled
                  onPressed: () {
                    // Proceed to the friends page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FriendsPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Formatting.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Jump In!',
                    style: Formatting.mediumStyle.copyWith(
                        fontSize: 16,
                        color: const Color.fromRGBO(255, 255, 255, 1)),
                  ),
                )),
          ],
        );
      },
    );
  }

  // Themes
  ThemeData theme() {
    return ThemeData(
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
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
