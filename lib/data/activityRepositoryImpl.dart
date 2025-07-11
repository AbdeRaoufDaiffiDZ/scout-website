// ignore_for_file: file_names

import 'package:scout/data/activityRemoteDataSource.dart';
import 'package:scout/domain/entities/activity .dart';
import 'package:scout/domain/repositories/activityRepository .dart';

/// Concrete implementation of [ActivityRepository].
/// It uses [ActivityRemoteDataSource] to get raw data and maps it to domain models.
class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;

  ActivityRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Activity>> getActivities({int page = 1, int limit = 10}) async {
    return await remoteDataSource.fetchActivitiesData(page: page, limit: limit);
  }

  @override
  Future<void> sendEmail({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    await remoteDataSource.sendEmail(
      name: name,
      email: email,
      subject: subject,
      message: message,
    );
  }
}
