// Import statements
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/firebase_options.dart';
import 'package:tolentino_mini_project/provider/auth_provider.dart';
import 'package:tolentino_mini_project/provider/user-friend_provider.dart';
import 'package:tolentino_mini_project/provider/image-storage_provider.dart';
import 'package:tolentino_mini_project/provider/user-info_provider.dart';
import 'package:tolentino_mini_project/provider/user-slambook_provider.dart';
import 'package:tolentino_mini_project/screens/pages/main_pages/friend_page.dart';
import 'package:tolentino_mini_project/screens/pages/main_pages/home_page.dart';
import 'package:tolentino_mini_project/screens/pages/main_pages/profile_page.dart';
import 'package:tolentino_mini_project/screens/pages/main_pages/slambook_page.dart';
import 'package:tolentino_mini_project/screens/pages/general%20pages/summary_page.dart';

Future<void> main() async {
  // Initializing the firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      // Providers
      providers: [
        ChangeNotifierProvider(create: ((context) => FriendListProvider())),
        ChangeNotifierProvider(create: ((context) => UserAuthProvider())),
        ChangeNotifierProvider(create: ((context) => UserInfoProvider())),
        ChangeNotifierProvider(create: ((context) => StorageProvider())),
        ChangeNotifierProvider(create: ((context) => UserSlambookProvider()))
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
      initialRoute: "/",
      onGenerateRoute: (settings) {
        if (settings.name == "/") {
          return MaterialPageRoute(builder: (context) => const HomePage());
        }
        if (settings.name == "/friendspage") {
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

        if (settings.name == "/profilepage") {
          return MaterialPageRoute(builder: (context) => const ProfilePage());
        }

        return null;
      },
    );
  }
}
