import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/formatting/formatting.dart';
import 'package:tolentino_mini_project/provider/auth_provider.dart';
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  double get screenWidth => MediaQuery.of(context).size.width;
  String? email;
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
    emailController.addListener(_checkFields);
    passwordController.addListener(_checkFields);
  }

  // Updates the button if the fields is not empty
  void _checkFields() {
    setState(() {
      if (emailController.text.isNotEmpty &&
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
            resizeToAvoidBottomInset: false,
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            body: Stack(children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 48, horizontal: 48),
                // Form for text fields for signing in
                child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // Text Fields and buttons
                        children: [
                          const SizedBox(height: 100),
                          // Logo
                          Container(
                            padding: const EdgeInsets.only(bottom: 80),
                            width: 200,
                            child: Image.asset("assets/ribbit_logo.png"),
                          ),
                          Row(children: [
                            heading,
                          ]),
                          emailField,
                          passwordField,
                          submitButton,
                          signUpButton,
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
                  .copyWith(fontSize: 28, color: Formatting.black),
            ),
            Text(
              "Sign in to your account",
              style: Formatting.regularStyle
                  .copyWith(fontSize: 14, color: Formatting.black),
            )
          ],
        ),
      );

  // Text field for email
  Widget get emailField => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: emailController,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              label: const Text("Email")),
          onSaved: (value) => email = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your email";
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
                  bool signinChecker = await context
                      .read<UserAuthProvider>()
                      .signIn(email!, password!);

                  setState(() {
                    // If message is not empty (error): show the error dialog
                    if (!signinChecker) {
                      showSignInErrorDialog(context);
                    }
                  });
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
        padding: const EdgeInsets.only(bottom: 16),
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
