import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/formatting/formatting.dart';
import 'package:tolentino_mini_project/android_features/camera_feat.dart';
import 'package:tolentino_mini_project/provider/auth_provider.dart';
import 'package:tolentino_mini_project/provider/user-info_provider.dart';
import 'package:tolentino_mini_project/screens/account_creation/sign-up-pages/signup_page2.dart';

// First Signup Page
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  // Variables
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  File? _imageFile;
  // password visibility
  bool obscurePassword = true;
  // disable button
  bool isButtonEnabled = false;
  OAuthCredential? credentials;
  String? profilePictureURL;
  bool enableEmail = false;

  double get screenWidth => MediaQuery.of(context).size.width;
  // Initializing camera feature
  final CameraFeature _cameraFeature = CameraFeature();

  // Updates the button if fields are empty
  void _checkFields() {
    setState(() {
      if (emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          nameController.text.isNotEmpty) {
        isButtonEnabled = true;
      } else {
        isButtonEnabled = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Listeners to the controllers
    emailController.addListener(_checkFields);
    passwordController.addListener(_checkFields);
    nameController.addListener(_checkFields);
    // Asking users permission
    _cameraFeature.requestPermission();
  }

  @override
  void dispose() {
    // Disposing controlers
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        // Theme
        data: theme(),
        child: Scaffold(
          // Scaffold Formatting
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          // Transparent appbar
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
            child: Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 48, horizontal: 48),
                // Form Field
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          heading,
                          profilePicture,
                          nameField,
                          emailField,
                          passwordField,
                          submitButton,
                          orText,
                          googleSignUpButton
                        ],
                      ),
                    )
                  ],
                )),
          ),
        ));
  }

  // Create account text
  Widget get heading => Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
          "Create Account",
          style: Formatting.semiBoldStyle.copyWith(fontSize: 32),
        ),
        Text(
          textAlign: TextAlign.center,
          "Join the pond! Input your details to start making froggy friends!",
          style: Formatting.regularStyle.copyWith(
            fontSize: 14,
          ),
        )
      ]));

  // Profile picture
  Widget get profilePicture => Stack(
        children: [
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: SizedBox(
                width: 140,
                height: 140,
                child: ClipOval(
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
            )
          else if (profilePictureURL != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: SizedBox(
                width: 140,
                height: 140,
                child: ClipOval(
                  child: Image.network(profilePictureURL!, fit: BoxFit.cover),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: SizedBox(
                width: 140,
                height: 140,
                child: ClipOval(
                  child:
                      Image.asset("assets/default_pfp.jpg", fit: BoxFit.cover),
                ),
              ),
            ),

          // Add Button
          Positioned(
            top: 100,
            right: 0,
            child: IconButton(
              // Calls photoOptions/camera
              onPressed: () => _photoOptions(context),
              icon: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(1),
                  child: Icon(Icons.add, color: Colors.black),
                ),
              ),
            ),
          )
        ],
      );

  // Name Text Field
  Widget get nameField => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Name"),
              hintText: "John Doe"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter a name";
            } else if (value.trim().isEmpty || int.tryParse(value) != null) {
              return "Please enter a valid name";
            }
            return null;
          },
        ),
      );

  // Email Text Field
  Widget get emailField => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          readOnly: enableEmail,
          controller: emailController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Email"),
              hintText: "Enter a valid email"),
          // Validators
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter a valid email format";
            }
            final emailRegExp = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
            );
            if (!emailRegExp.hasMatch(value)) {
              return "Please enter a valid email format";
            }
            return null;
          },
        ),
      );

  // Password Text Field
  Widget get passwordField => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            label: const Text("Password"),
            hintText: "At least 8 characters",
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            ),
          ),
          obscureText: obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter a valid password";
            }
            if (value.length < 8) {
              return "Password must be at least 8 characters long";
            }
            return null;
          },
        ),
      );

  // Submit button
  Widget get submitButton => SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        // Show button if enabled
        onPressed: isButtonEnabled
            ? () async {
                if (_formKey.currentState!.validate()) {
                  // Navigate to the next sign up page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          // Pass the variables to the next page
                          builder: (context) => SignupInfoPage(
                              name: nameController.text,
                              email: emailController.text,
                              password: passwordController.text,
                              imageFile: _imageFile,
                              profilePictureURL: profilePictureURL,
                              credentials: credentials)));
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
          'Next',
          style: Formatting.mediumStyle.copyWith(
              fontSize: 16, color: const Color.fromRGBO(255, 255, 255, 1)),
        ),
      ));

  // Google sign up
  Widget get googleSignUpButton => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          Map<String, dynamic>? userCredentials =
              await context.read<UserAuthProvider>().signUpWithGoogle();
          // Checks if the email used is already existing
          if (userCredentials != null) {
            setState(() {
              nameController.text = userCredentials["name"];
              emailController.text = userCredentials["email"];
              profilePictureURL = userCredentials["profilePictureURL"];
              credentials = userCredentials["credentials"];
              enableEmail = true;
            });
          } else {
            showSignInErrorDialog(context);
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 5, // Button shadow
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/google_logo.png',
              height: 24.0,
            ),
            SizedBox(width: 12),
            Text(
              'Sign Up with Google',
              style: Formatting.mediumStyle
                  .copyWith(fontSize: 14, color: Formatting.black),
            ),
          ],
        ),
      ));

  // Or text divider
  Widget get orText => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Divider
          Container(
            decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.105)),
            height: 2,
            width: screenWidth * 0.32,
          ),
          // Text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'Or',
              style: Formatting.regularStyle.copyWith(
                  fontSize: 12,
                  color: const Color.fromARGB(255, 102, 102, 102)),
            ),
          ),
          // Divider
          Container(
            decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.105)),
            height: 2,
            width: screenWidth * 0.32,
          ),
        ],
      );

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
            // Delete option
            if (_imageFile != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    _imageFile = null;
                  });
                },
              )
          ],
        );
      },
    );
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
