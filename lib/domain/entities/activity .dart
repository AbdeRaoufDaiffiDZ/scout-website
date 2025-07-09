import 'package:scout/domain/entities/activityTranslation%20.dart';

class Activity {
  final String id; // MongoDB _id is a String
  final String date;
  final List<String> pics;
  final Map<String, ActivityTranslation> translations;

  Activity({
    required this.id,
    required this.date,
    required this.pics,
    required this.translations,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'], // Use _id from MongoDB
      date: json['date'],
      pics: List<String>.from(json['pics'] ?? []), // Handle null pics
      translations: (json['translations'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          ActivityTranslation.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'pics': pics,
      'translations': translations.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}
