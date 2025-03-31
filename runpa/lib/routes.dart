import 'package:flutter/material.dart';
import 'package:runpa/home.dart';
import 'package:runpa/pages/athletes.dart';
import 'package:runpa/pages/challenge_run.dart';
import 'package:runpa/pages/take_picture.dart';

class AppRoutes {
  static const String home = '/';
  static const String athletes = '/athletes';
  static const String takePicture = '/take-picture';
  static const String challengeRun = '/challenge-run';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => HomePage());

      case athletes:
        return MaterialPageRoute(builder: (context) => Athletes());

      case takePicture:
        return MaterialPageRoute(builder: (context) => TakePictureScreen());

      case challengeRun:
        final args = settings.arguments as Map?;
        final authCode = args?['code'];

        return MaterialPageRoute(
          builder: (context) => ChallengeRunScreen(authCode: authCode),
        );

      default:
        final uri = Uri.parse(settings.name ?? '');
        final authCode = uri.queryParameters['code'];

        if (authCode != null) {
          return MaterialPageRoute(
            builder: (context) => ChallengeRunScreen(authCode: authCode),
          );
        }

        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text("404 - Pagina non trovata, ${settings.name}")),
          ),
        );
    }
  }
}
