import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tolentino_mini_project/formatting/formatting.dart';
import 'package:tolentino_mini_project/android_features/camera_feat.dart';
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
          "Halika na! Enter your credentials to start making friends!",
          style: Formatting.regularStyle.copyWith(
            fontSize: 14,
          ),
        )
      ]));

  // Profile picture
  Widget get profilePicture => Stack(
        children: [
          // If no image file existing, show the default pfp
          _imageFile != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: SizedBox(
                      width: 140,
                      height: 140,
                      child: ClipOval(
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )))
              : Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: SizedBox(
                      width: 140,
                      height: 140,
                      child: ClipOval(
                        child: Image.asset("assets/default_pfp.jpg",
                            fit: BoxFit.cover),
                      ))),
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
            }
            return null;
          },
        ),
      );

  // Email Text Field
  Widget get emailField => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: emailController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Email"),
              hintText: "Enter a valid email"),
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
                              )));
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
