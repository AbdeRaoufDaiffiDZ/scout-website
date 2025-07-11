/// Abstract interface for fetching activities.
/// This is what the Presentation layer (e.g., ViewModel/Provider) will depend on.
///
// ignore_for_file: file_names

library;

import 'package:scout/domain/entities/activity .dart';

abstract class ActivityRepository {
  Future<List<Activity>> getActivities({int page = 1, int limit = 10});
  Future<void> sendEmail({
    required String name,
    required String email,
    required String subject,
    required String message,
  });
}
