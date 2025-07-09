import 'dart:convert'; // For jsonDecode
import 'package:http/http.dart' as http; // As 'http' for convenience

// You might need these DTOs or models if your backend returns structured data
// Ensure your Activity and ActivityTranslation models can be created from JSON
// import 'package:scout/domain/entities/activity.dart'; // Assuming these exist
// import 'package:scout/domain/entities/activityTranslation.dart';

class ActivityRemoteDataSource {
  // Replace this with the actual URL of your backend API endpoint
  // Make sure this URL is accessible from your Flutter web app (e.g., same origin or proper CORS setup on backend)
  final String _baseUrl = 'http://localhost:5000/api/activities'; // Example URL

  Future<List<Map<String, dynamic>>> fetchActivitiesData() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON.
        List<dynamic> jsonList = jsonDecode(response.body);

        // Ensure that each item in the list is cast to Map<String, dynamic>
        return jsonList.map((item) => item as Map<String, dynamic>).toList();
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception(
          'Failed to load activities: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      // Handle network errors or other exceptions
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
