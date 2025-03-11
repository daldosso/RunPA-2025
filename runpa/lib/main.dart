import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:runpa/routes.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  final AppLinks _appLinks = AppLinks();

  void _initDeepLinkListener() {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.queryParameters.containsKey('code')) {
        String? authCode = uri.queryParameters['code'];
        print("✅ Deep Link received, code: $authCode");
        navigatorKey.currentState?.pushNamed(
          AppRoutes.challengeRun,
          arguments: {'code': authCode},
        );
      }
    }, onError: (err) {
      print("❌ Error in deep linking: $err");
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'RunPA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
