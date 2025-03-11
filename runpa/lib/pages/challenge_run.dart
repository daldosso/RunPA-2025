import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../strava_auth_service.dart';
import 'package:intl/intl.dart';

class ChallengeRunScreen extends StatefulWidget {
  final String? authCode;

  const ChallengeRunScreen({super.key, this.authCode});

  @override
  _ChallengeRunScreenState createState() => _ChallengeRunScreenState();
}

class _ChallengeRunScreenState extends State<ChallengeRunScreen> {
  final StravaAuthService stravaAuthService = StravaAuthService();
  List<dynamic> activities = [];
  String? accessToken;
  final String backendUrl = dotenv.env['STRAVA_API_URL'] ?? '';
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authCode = widget.authCode;

      if (authCode != null) {
        authenticateWithStrava(authCode);
      } else {
        authenticateAndFetchActivities();
      }
    });
  }

  Future<void> authenticateWithStrava(String authCode) async {
    String? token = await stravaAuthService.signInWithStrava(authCode);
    if (token != null) {
      setState(() {
        accessToken = token;
      });
      fetchActivities();
    }
  }

  Future<void> authenticateAndFetchActivities() async {
    String? token = await stravaAuthService.getAccessToken();
    if (token == null) {
      final String? authCode = await stravaAuthService.getAuthorizationCode();
      if (authCode != null) {
        token = await stravaAuthService.signInWithStrava(authCode);
      }
    }
    if (token != null) {
      setState(() {
        accessToken = token;
      });
      fetchActivities();
    }
  }

  Future<void> fetchActivities() async {
    if (accessToken == null) return;

    final response = await http.get(
      Uri.parse("$backendUrl/athlete/activities"),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      setState(() {
        activities = json.decode(response.body);
      });
    } else {
      throw Exception('Errore nel caricamento delle attività');
    }
  }

  String calculatePace(double distanceMeters, int movingTimeSeconds) {
    if (distanceMeters == 0) return 'N/A';
    final paceSecondsPerKm = movingTimeSeconds / (distanceMeters / 1000);
    final minutes = paceSecondsPerKm ~/ 60;
    final seconds = (paceSecondsPerKm % 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')} min/km';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Challenge Run')),
      body: activities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          final distanceKm =
          (activity['distance'] / 1000).toStringAsFixed(2);
          final durationMinutes =
          (activity['moving_time'] / 60).round();
          final elevationGain =
          (activity['total_elevation_gain'] ?? 0).toStringAsFixed(0);
          final avgHeartRate = activity['average_heartrate'] != null
              ? '${activity['average_heartrate'].toStringAsFixed(1)} bpm'
              : 'N/A';
          final pace = calculatePace(
              activity['distance'], activity['moving_time']);

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(activity['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Data: ${dateFormat.format(DateTime.parse(activity['start_date_local']))}'),
                  Text('Distanza: $distanceKm km'),
                  Text('Passo medio: $pace'),
                  Text('Durata: ${(activity['moving_time'] / 60).round()} minuti'),
                  Text('Dislivello: ${activity['total_elevation_gain'].toStringAsFixed(0)} m'),
                  Text('FC media: $avgHeartRate'),
                ],
              ),
              trailing: const Icon(Icons.directions_run),
            ),
          );
        },
      ),
    );
  }
}
