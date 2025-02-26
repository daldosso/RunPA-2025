import 'package:flutter/material.dart';
import 'package:runpa/home.dart';
import 'package:runpa/pages/athletes.dart';
import 'package:runpa/pages/take_picture.dart';

class AppRoutes {
  static const String home = '/';
  static const String athletes = '/athletes';
  static const String takePicture = '/take_picture';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => HomePage());

      case athletes:
        return MaterialPageRoute(builder: (context) => Athletes());

      case takePicture:
        return MaterialPageRoute(builder: (context) => TakePictureScreen());

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text("404 - Pagina non trovata")),
          ),
        );
    }
  }
}
