import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/formatting/formatting.dart';
import 'package:tolentino_mini_project/provider/auth_provider.dart';
import 'package:tolentino_mini_project/provider/user-info_provider.dart';
import 'package:tolentino_mini_project/screens/account_creation/sign-up-pages/signup_page1.dart';

// Sign In Page
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Variables
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;
  String? username;
  String? password;
  bool showSignInErrorMessage = false;
  // button disabler
  bool isButtonEnabled = false;
  // password visibility
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // adding listeners to the controllers
    usernameController.addListener(_checkFields);
    passwordController.addListener(_checkFields);
  }

  // Updates the button if the fields is not empty
  void _checkFields() {
    setState(() {
      if (usernameController.text.isNotEmpty &&
          passwordController.text.isNotEmpty) {
        isButtonEnabled = true;
      } else {
        isButtonEnabled = false;
      }
    });
  }

  @override
  void dispose() {
    // Disposing controllers
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        // Theme
        data: theme(),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            body: Stack(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 48, horizontal: 48),
                // Form for text fields for signing in
                child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // Text Fields and buttons
                        children: [
                          SizedBox(height: screenHeight * 0.1),
                          // Logo
                          Container(
                            padding:
                                EdgeInsets.only(bottom: screenHeight * 0.05),
                            width: 200,
                            child: Image.asset("assets/ribbit_logo.png"),
                          ),
                          Row(children: [
                            heading,
                          ]),
                          // Fields and buttons
                          usernameField,
                          passwordField,
                          submitButton,
                          signUpButton,
                          orText,
                          googleSignInButton,
                        ],
                      ),
                    )),
              ),
            ])));
  }

  // Sign in Text
  Widget get heading => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hop hop, how are you?",
              style: Formatting.boldStyle
                  .copyWith(fontSize: 24, color: Formatting.black),
            ),
            Text(
              "Sign in to your account",
              style: Formatting.regularStyle
                  .copyWith(fontSize: 14, color: Formatting.black),
            )
          ],
        ),
      );

  // Text field for username
  Widget get usernameField => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: usernameController,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              label: const Text("Username")),
          onSaved: (value) => username = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your username";
            }
            return null;
          },
        ),
      );

  // Text field for password
  Widget get passwordField => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            label: const Text("Password"),
            // Show password when enabled
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
          onSaved: (value) => password = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your password";
            }
            return null;
          },
        ),
      );

// Sign in using google
  Widget get googleSignInButton => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // Checks if its username is existing in the firebase
          List<String?> emails =
              await context.read<UserInfoProvider>().getAllEmails();
          final result =
              await context.read<UserAuthProvider>().signInWithGoogle(emails);
          // If existing, show error
          if (result == false) showSignInErrorDialog(context);
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
              'Login with Google',
              style: Formatting.mediumStyle
                  .copyWith(fontSize: 14, color: Formatting.black),
            ),
          ],
        ),
      ));

// Or divider text
  Widget get orText => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Divider
          Container(
            decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.105)),
            height: 2,
            width: screenWidth * 0.3,
          ),
          // Text
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 16, vertical: screenHeight * 0.02),
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
            width: screenWidth * 0.3,
          ),
        ],
      );

  // Sign in button
  Widget get submitButton => SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        // Show button if enabled
        onPressed: isButtonEnabled
            ? () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  String? email = await getEmailByUsername(username!);

                  if (email != null) {
                    // Checks if the user signed in successful
                    bool signinChecker = await context
                        .read<UserAuthProvider>()
                        .signIn(email, password!);

                    setState(() {
                      // If message is not empty (error): show the error dialog
                      if (!signinChecker) {
                        showSignInErrorDialog(context);
                      }
                    });
                  } else {
                    showSignInErrorDialog(context);
                  }
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
          'Sign in',
          style: Formatting.mediumStyle.copyWith(
              fontSize: 16, color: const Color.fromRGBO(255, 255, 255, 1)),
        ),
      ));

  // Returns email by username
  Future<String?> getEmailByUsername(String usernameToCheck) async {
    try {
      // Get the list of all usernames and emails
      List<Map<String, dynamic>> usernamesAndEmails =
          await context.read<UserInfoProvider>().getUsernameAndEmail();

      // Iterate through the list to find the email linked to the specified username
      for (var user in usernamesAndEmails) {
        if (user['username'] == usernameToCheck) {
          return user['email'];
        }
      }
      // If no matching username is found, return null
      return null;
    } catch (e) {
      print("Error fetching email by username: $e");
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
                  "We couldn’t sign you in. Please check your username and password and try again.",
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
                  // Show button if enabled
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

  // Sign up button
  Widget get signUpButton => Padding(
        padding: EdgeInsets.only(bottom: screenHeight / 1000),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No account yet?",
              style: Formatting.regularStyle
                  .copyWith(fontSize: 12, color: Formatting.black),
            ),
            TextButton(
                // Navigate to the sign up page when pressed
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpPage()));
                },
                child: Text(
                  "Sign Up",
                  style: Formatting.semiBoldStyle
                      .copyWith(fontSize: 12, color: Formatting.black),
                ))
          ],
        ),
      );

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
        labelStyle: const TextStyle(color: Formatting.black),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}
