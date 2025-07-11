// ignore_for_file: file_names

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scout/domain/entities/activity%20.dart';

final String baseUrl = 'http://localhost:5000'; // Your backend activities URL

class ActivityRemoteDataSource {
  // Replace this with the actual URL of your backend API endpoint
  // Make sure this URL is accessible from your Flutter web app (e.g., same origin or proper CORS setup on backend)
  Future<void> sendEmail({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/activities/send-email"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'subject': subject,
          'message': message,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to send email: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      // Handle network errors or other exceptions
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Modified to fetch paginated data
  Future<List<Activity>> fetchActivitiesData({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/activities?page=$page&limit=$limit"),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> activitiesJson = jsonResponse['activities'];

        // You might want to return pagination metadata as well,
        // but for now, we'll just return the list of activities.
        // The provider will manage the pagination state.
        return activitiesJson
            .map((item) => Activity.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to load activities: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
