import 'package:exer5_navigation_app/homepage.dart';
import 'package:exer5_navigation_app/slambook.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SplashScreen());
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/homepage",
      onGenerateRoute: (settings) {
        if (settings.name == "/homepage") {
          return MaterialPageRoute(builder: (context) => const HomePage());
        }

        if (settings.name == "/slambookpage") {
          return MaterialPageRoute(builder: (context) => const SlamBook());
        }

        return null;
      },
    );
  }
}
