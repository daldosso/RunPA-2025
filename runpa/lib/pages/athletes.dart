import 'package:flutter/material.dart';
import 'dart:convert';
import 'athlete.dart';

class Athletes extends StatelessWidget {
  final String mockJson = '''
  [  
    {"id": 1, "firstName": "Alberto", "lastName": "Dal Dosso", "dateOfBirth": "1986-05-12", "imageUrl": "https://picsum.photos/200?random=1"},
    {"id": 2, "firstName": "Marco", "lastName": "Rossi", "dateOfBirth": "1992-08-23", "imageUrl": "https://picsum.photos/200?random=2"},
    {"id": 3, "firstName": "Luca", "lastName": "Bianchi", "dateOfBirth": "1995-11-14", "imageUrl": "https://picsum.photos/200?random=3"},
    {"id": 4, "firstName": "Giulia", "lastName": "Verdi", "dateOfBirth": "1990-06-10", "imageUrl": "https://picsum.photos/200?random=4"},
    {"id": 5, "firstName": "Elena", "lastName": "Moretti", "dateOfBirth": "1988-07-25", "imageUrl": "https://picsum.photos/200?random=5"}
  ]  
  ''';

  const Athletes({super.key});

  List<Athlete> parseAthletes() {
    final List<dynamic> jsonData = jsonDecode(mockJson);
    return jsonData.map((json) => Athlete.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Athlete> athletes = parseAthletes();

    return Scaffold(
      appBar: AppBar(title: Text('Lista Atleti')),
      body: ListView.builder(
        itemCount: athletes.length,
        itemBuilder: (context, index) {
          final athlete = athletes[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(athlete.imageUrl),
              ),
              title: Text('${athlete.firstName} ${athlete.lastName}'),
              subtitle: Text('Nato il: ${athlete.dateOfBirth}'),
            ),
          );
        },
      ),
    );
  }
}
