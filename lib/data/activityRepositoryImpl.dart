import 'package:flutter/foundation.dart';
import 'package:scout/data/activityRemoteDataSource.dart';
import 'package:scout/domain/entities/activity .dart';
import 'package:scout/domain/entities/activityTranslation .dart';
import 'package:scout/domain/repositories/activityRepository .dart';

/// Concrete implementation of [ActivityRepository].
/// It uses [ActivityRemoteDataSource] to get raw data and maps it to domain models.
class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;

  ActivityRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Activity>> getActivities() async {
    try {
      final List<Map<String, dynamic>> data = await remoteDataSource
          .fetchActivitiesData();
      return data.map((json) {
        final Map<String, ActivityTranslation> translations = {};
        if (json['translations'] != null) {
          (json['translations'] as Map<String, dynamic>).forEach((lang, value) {
            translations[lang] = ActivityTranslation(
              title: value['title'],
              description: value['description'],
            );
          });
        }
        return Activity(
          id: json['_id'],
          date: json['date'],
          pics: List<String>.from(json['pics'] ?? []),
          translations: translations,
        );
      }).toList();
    } catch (e) {
      // In a real app, this would be more robust error handling (e.g., network error)
      debugPrint('Error fetching activities: $e');
      rethrow; // Re-throw to be caught by the Presentation layer
    }
  }
}
