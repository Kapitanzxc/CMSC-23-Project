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
  bool isButtonEnabled = false;
  bool obscurePassword = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_checkFields);
    passwordController.addListener(_checkFields);
  }

  // Updates the button if email and password field is not empty
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: theme(),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            body: Stack(children: [
              // Container(
              //     decoration: const BoxDecoration(
              //   image: DecorationImage(
              //     image: AssetImage("assets/background_signin.jpg"),
              //     fit: BoxFit.cover,
              //   ),
              // )),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 48, horizontal: 48),
                // Form for text field for signing in
                child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // Text Fields and buttons
                        children: [
                          const SizedBox(height: 80),
                          Container(
                            padding: const EdgeInsets.only(bottom: 80),
                            width: 80,
                            child: Image.asset("assets/kaibigan_logo3.png"),
                          ),
                          Row(children: [
                            heading,
                          ]),
                          emailField,
                          passwordField,
                          submitButton,
                          signUpButton,
                          orText
                        ],
                      ),
                    )),
              ),
            ])));
  }

  ThemeData theme() {
    return ThemeData(
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(color: Formatting.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
        labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        errorStyle: TextStyle(color: Colors.red),
      ),
    );
  }

  // Sign in Text
  Widget get heading => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, kumusta ka?",
              style: Formatting.boldStyle.copyWith(fontSize: 32),
            ),
            Text(
              "Sign in to your account",
              style: Formatting.regularStyle.copyWith(fontSize: 12),
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
              label: Text("Email")),
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
            label: Text("Password"),
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

  // Error Message
  Widget get signInErrorMessage => const Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: Text(
          "Invalid email or password",
          style: TextStyle(color: Colors.red),
        ),
      );

  // Sign in
  Widget get submitButton => SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        // Show button if enabled
        onPressed: isButtonEnabled
            ? () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  String? message = await context
                      .read<UserAuthProvider>()
                      .signIn(email!, password!);

                  print(message);
                  print(showSignInErrorMessage);

                  setState(() {
                    if (message.isNotEmpty) {
                      showSignInErrorMessage = true;
                    } else {
                      showSignInErrorMessage = false;
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

  // Sign up button
  Widget get signUpButton => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No account yet?",
              style: Formatting.regularStyle.copyWith(fontSize: 12),
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpPage()));
                },
                child: Text(
                  "Sign Up",
                  style: Formatting.semiBoldStyle
                      .copyWith(fontSize: 12, color: Colors.black),
                ))
          ],
        ),
      );

  // Sign up button
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
}
