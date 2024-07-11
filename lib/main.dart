// Import statements
import 'package:flutter/material.dart';
import 'package:tolentino_exer7_firebase/provider/friends_provider.dart';
import 'package:tolentino_exer7_firebase/screens/friend_page.dart';
import 'package:tolentino_exer7_firebase/screens/slambook_page.dart';
import 'package:tolentino_exer7_firebase/screens/summary_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  // Initializing the firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      // Friend List Provider
      providers: [
        ChangeNotifierProvider(create: ((context) => FriendListProvider())),
      ],
      child: const SplashScreen(),
    ),
  );
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slambook App',
      // Declaring routes
      initialRoute: "friendspage",
      onGenerateRoute: (settings) {
        if (settings.name == "/") {
          return MaterialPageRoute(builder: (context) => const FriendsPage());
        }

        if (settings.name == "/slambook") {
          return MaterialPageRoute(builder: (context) => const SlamBook());
        }

        if (settings.name == "/summary") {
          final friendListValues = settings.arguments as List;
          return MaterialPageRoute(
              builder: (context) =>
                  SummaryPage(friendListValues: friendListValues));
        }

        return null;
      },
    );
  }
}
