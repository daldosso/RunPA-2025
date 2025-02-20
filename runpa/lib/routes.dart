import 'package:flutter/material.dart';
import 'package:runpa/home.dart';
import 'package:runpa/pages/athletes.dart';

class AppRoutes {
  static const String home = '/';
  static const String athletes = '/athletes';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => HomePage());

      case athletes:
        return MaterialPageRoute(builder: (context) => Athletes());

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text("404 - Pagina non trovata")),
          ),
        );
    }
  }
}
