/// Abstract interface for fetching activities.
/// This is what the Presentation layer (e.g., ViewModel/Provider) will depend on.
///
import 'package:scout/domain/entities/activity .dart';

abstract class ActivityRepository {
  Future<List<Activity>> getActivities();
}
