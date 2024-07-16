/*
  Created by: Claizel Coubeili Cepe
  Date: updated April 26, 2023
  Description: Sample todo app with Firebase 
*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/provider/auth_provider.dart';
import 'package:tolentino_mini_project/screens/account_creation/sign-in-pages/signin_page.dart';
import 'package:tolentino_mini_project/screens/pages/friend_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    Stream<User?> userStream = context.watch<UserAuthProvider>().userStream;

    return StreamBuilder(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text("Error encountered! ${snapshot.error}"),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (!snapshot.hasData) {
            return const SignInPage(); // Will go to the sign in page if user is not logged in
          }

          // if user is logged in, display the scaffold containing the streambuilder for the todos
          return const FriendsPage();
        });
  }
}
