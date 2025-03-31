import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StravaAuthService {
  final storage = const FlutterSecureStorage();
  final clientId = dotenv.env['STRAVA_CLIENT_ID'] ?? '';
  final redirectUri = dotenv.env['STRAVA_REDIRECT_URI'] ?? '';
  final backendUrl = dotenv.env['BACKEND_URL'] ?? '';
  final authorizationEndpoint = dotenv.env['STRAVA_AUTHORIZATION_ENDPOINT'] ?? '';
  late final String tokenEndpoint = "$backendUrl/strava/exchange_token";

  final FlutterAppAuth appAuth = FlutterAppAuth();

  Future<String?> getAuthorizationCode() async {
    final result = await appAuth.authorize(
      AuthorizationRequest(
        clientId,
        redirectUri,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: authorizationEndpoint,
          tokenEndpoint: tokenEndpoint,
        ),
        scopes: ['activity:read_all'],
      ),
    );
    return result?.authorizationCode;
  }

  Future<String?> signInWithStrava(String authorizationCode) async {
    final response = await http.post(
      Uri.parse(tokenEndpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"code": authorizationCode}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storeTokenData(data);
      return data["access_token"];
    }
    return null;
  }

  Future<void> _storeTokenData(Map<String, dynamic> data) async {
    await storage.write(key: "access_token", value: data["access_token"]);
    await storage.write(key: "refresh_token", value: data["refresh_token"]);
    await storage.write(
      key: "expires_at",
      value: DateTime.fromMillisecondsSinceEpoch(data["expires_at"] * 1000)
          .toIso8601String(),
    );
  }

  Future<String?> getAccessToken() async {
    final expiresAtString = await storage.read(key: "expires_at");
    if (expiresAtString == null) return null;

    final expiresAt = DateTime.parse(expiresAtString);
    final now = DateTime.now();

    if (now.isAfter(expiresAt)) {
      return await refreshToken();
    }

    return await storage.read(key: "access_token");
  }

  Future<String?> refreshToken() async {
    final refreshToken = await storage.read(key: "refresh_token");
    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse("$backendUrl/strava/refresh_token"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh_token": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storeTokenData(data);
      return data["access_token"];
    }
    return null;
  }

  Future<String?> getValidAccessToken() async {
    final expiresAtString = await storage.read(key: "expires_at");
    final now = DateTime.now();

    if (expiresAtString == null || DateTime.parse(expiresAtString).isBefore(now)) {
      return await refreshToken();
    }

    return await storage.read(key: "access_token");
  }
}
