import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scout/data/activityRemoteDataSource.dart';
import 'package:scout/domain/entities/activity%20.dart';
import 'dart:convert';

import 'package:scout/domain/repositories/activityRepository%20.dart';

class AdminActivityProvider extends ChangeNotifier {
  final ActivityRepository _repository;

  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Pagination states
  int _currentPage = 1;
  final int _limit = 10; // Number of items per page
  bool _hasMore = true; // True if there are more activities to load
  bool _isFetchingMore = false;

  AdminActivityProvider({required ActivityRepository repository})
    : _repository =
          repository; // To prevent multiple simultaneous "load more" calls

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;

  // Updated fetchActivities for initial load and refresh
  Future<void> fetchActivities(String token, {bool refresh = false}) async {
    if (_isLoading || _isFetchingMore) {
      return; // Prevent multiple simultaneous fetches
    }

    if (refresh) {
      _activities = [];
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return; // Don't fetch if no more activities

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newActivities = await _repository.getActivities(
        page: _currentPage,
        limit: 10,
        token: token,
      );
      _activities.addAll(newActivities);
      _currentPage++;
      _hasMore =
          newActivities.length ==
          10; // Assuming 10 is the limit, if less, no more pages
    } catch (e) {
      _errorMessage = 'Failed to load activities: ${e.toString()}';
      // Do not clear activities on error during incremental load, just show error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // New function to fetch more activities (for infinite scrolling)
  Future<void> loadMoreActivities({bool refresh = false}) async {
    if (_isLoading || _isFetchingMore || !_hasMore) {
      return; // Prevent multiple fetches
    }

    _isFetchingMore = true;
    _errorMessage = null; // Clear previous error
    notifyListeners();

    try {
      final newActivities = await _repository.getActivities(
        page: _currentPage,
        limit: 10,
      );
      _activities.addAll(newActivities);
      _currentPage++;
      _hasMore =
          newActivities.length == 10; // If less than limit, it's the last page
    } catch (e) {
      _errorMessage = 'Failed to load more activities: ${e.toString()}';
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<bool> createActivity({
    required String date,
    required String titleEn,
    required String descriptionEn,
    required String titleAr,
    required String descriptionAr,
    List<String>? imageUrls, // Now a list of strings (URLs)
    required String token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/activities"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'date': date,
          'pics': imageUrls ?? [], // Send list of URLs
          'translations': {
            'en': {'title': titleEn, 'description': descriptionEn},
            'ar': {'title': titleAr, 'description': descriptionAr},
          },
        }),
      );

      if (response.statusCode == 201) {
        final newActivity = Activity.fromJson(jsonDecode(response.body));
        _activities.insert(0, newActivity); // Add to the beginning of the list
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            jsonDecode(response.body)['message'] ??
            'Failed to create activity: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateActivity({
    required String activityId,
    required String date,
    required String titleEn,
    required String descriptionEn,
    required String titleAr,
    required String descriptionAr,
    List<String>? imageUrls, // Now a list of strings (URLs)
    required String token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/activities/$activityId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'date': date,
          'pics': imageUrls ?? [], // Send updated list of URLs
          'translations': {
            'en': {'title': titleEn, 'description': descriptionEn},
            'ar': {'title': titleAr, 'description': descriptionAr},
          },
        }),
      );

      if (response.statusCode == 200) {
        final updatedActivity = Activity.fromJson(jsonDecode(response.body));
        int index = _activities.indexWhere((act) => act.id == activityId);
        if (index != -1) {
          _activities[index] = updatedActivity;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            jsonDecode(response.body)['message'] ??
            'Failed to update activity: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteActivity(String activityId, String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/activities/$activityId'), // Corrected URL
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _activities.removeWhere((activity) => activity.id == activityId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            jsonDecode(response.body)['message'] ??
            'Failed to delete activity: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
