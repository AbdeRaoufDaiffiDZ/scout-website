import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scout/domain/entities/activity%20.dart';
import 'dart:convert';
// import 'dart:typed_data'; // No longer needed if not handling file bytes

class AdminActivityProvider extends ChangeNotifier {
  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final String _baseUrl =
      'http://localhost:5000/api/activities'; // Your backend activities URL

  Future<void> fetchActivities(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        _activities = jsonList.map((json) => Activity.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage =
            jsonDecode(response.body)['message'] ??
            'Failed to load activities: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      _isLoading = false;
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
        Uri.parse(_baseUrl),
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
        _activities.add(newActivity);
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
        // Or PATCH if your backend is configured for it
        Uri.parse('$_baseUrl/$activityId'),
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
        Uri.parse('$_baseUrl/$activityId'),
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
