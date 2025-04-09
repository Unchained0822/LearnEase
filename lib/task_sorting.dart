// task_sorting.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TaskSortingService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  final String apiKey;

  TaskSortingService(this.apiKey);

  Future<String> sortTasksWithGemini(List<Map<String, dynamic>> tasks) async {
    try {
      // Format tasks for the prompt
      final taskDescriptions = tasks.map((task) =>
      '${task['task']} (Due: ${DateFormat('MMM dd').format(task['date'])} | Difficulty: ${task['difficulty']})'
      ).join('\n');

      final url = Uri.parse('$_baseUrl?key=$apiKey');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{
            "parts": [{
              "text": "Sort these tasks by priority considering both difficulty and due date. "
                  "Harder tasks with closer due dates should come first. "
                  "Return ONLY the original task names in priority order, one per line. "
                  "Do not include dates or difficulties in the response. "
                  "Here are the tasks:\n$taskDescriptions"
            }]
          }],
          "generationConfig": {
            "temperature": 0.3,
            "topP": 0.8,
            "maxOutputTokens": 1000
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }
}