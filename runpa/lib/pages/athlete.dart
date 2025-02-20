class Athlete {
  final int id;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String imageUrl;

  Athlete({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.imageUrl,
  });

  factory Athlete.fromJson(Map<String, dynamic> json) {
    return Athlete(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: json['dateOfBirth'],
      imageUrl: json['imageUrl'],
    );
  }
}
