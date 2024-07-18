import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/provider/auth_provider.dart';
import 'package:tolentino_mini_project/screens/account_creation/sign-in-pages/signin_page.dart';
import 'package:tolentino_mini_project/screens/pages/main_pages/friend_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    print("InitState: Fetching user stream.");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserAuthProvider>().fetchUserStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Checks the userStream if there is user logged in
    Stream<User?> userStream = context.watch<UserAuthProvider>().userStream;
    print("Build: Checking user stream.");

    return StreamBuilder(
        stream: userStream,
        builder: (context, snapshot) {
          // Catching error
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text("Error encountered! ${snapshot.error}"),
              ),
            );
            // When connection is loading:
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (!snapshot.hasData) {
            print("StreamBuilder: No user logged in.");
            return const SignInPage(); // Will go to the sign in page if user is not logged in
          }
          // if user is logged in, go to friends page
          print("StreamBuilder: User logged in, navigating to FriendsPage.");
          return const FriendsPage();
        });
  }
}
