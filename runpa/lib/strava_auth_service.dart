import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StravaAuthService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final FlutterAppAuth appAuth = FlutterAppAuth();
  static final String backendUrl = dotenv.env['BACKEND_URL'] ?? '';
  final String clientId = dotenv.env['STRAVA_CLIENT_ID'] ?? '';
  final String redirectUri = dotenv.env['STRAVA_REDIRECT_URI'] ?? '';
  final String authorizationEndpoint = dotenv.env['STRAVA_AUTHORIZATION_ENDPOINT'] ?? '';
  final String tokenEndpoint = "$backendUrl/strava/exchange_token";

  Future<String?> getAuthorizationCode() async {
    final AuthorizationResponse? result = await appAuth.authorize(
      AuthorizationRequest(
        clientId,
        redirectUri,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: authorizationEndpoint,
          tokenEndpoint: tokenEndpoint,
        ),
        scopes: ["activity:read_all"],
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
      final data = json.decode(response.body);
      await secureStorage.write(key: "access_token", value: data["access_token"]);
      await secureStorage.write(key: "refresh_token", value: data["refresh_token"]);
      await secureStorage.write(
          key: "expires_at",
          value: DateTime.fromMillisecondsSinceEpoch(data["expires_at"] * 1000).toIso8601String());
      return data["access_token"];
    } else {
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    final accessToken = await secureStorage.read(key: "access_token");
    if (accessToken != null) {
      return accessToken;
    } else {
      return await refreshToken();
    }
  }

  Future<String?> refreshToken() async {
    final refreshToken = await secureStorage.read(key: "refresh_token");
    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse("$backendUrl/strava/refresh_token"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh_token": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await secureStorage.write(key: "access_token", value: data["access_token"]);
      await secureStorage.write(key: "refresh_token", value: data["refresh_token"]);
      await secureStorage.write(
          key: "expires_at",
          value: DateTime.fromMillisecondsSinceEpoch(data["expires_at"] * 1000).toIso8601String());
      return data["access_token"];
    } else {
      return null;
    }
  }
}