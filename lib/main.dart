// Import statements
import 'package:exer5_app/friends.dart';
import 'package:exer5_app/slambook.dart';
import 'package:exer5_app/summary.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SplashScreen());
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Defining the routes
    return MaterialApp(
      // Initial route is the friends page
      initialRoute: "/friendspage",
      onGenerateRoute: (settings) {
        if (settings.name == "/friendspage") {
          return MaterialPageRoute(builder: (context) => const FriendsPage());
        }

        if (settings.name == "/slambookpage") {
          final friendList = settings.arguments as Map<String, List<dynamic>>;
          return MaterialPageRoute(
              builder: (context) => SlamBook(friendList: friendList));
        }

        if (settings.name == "/summarypage") {
          final friendListSettings = settings.arguments as List;
          return MaterialPageRoute(
              builder: (context) =>
                  SummaryPage(friendListSettings: friendListSettings));
        }

        return null;
      },
    );
  }
}
