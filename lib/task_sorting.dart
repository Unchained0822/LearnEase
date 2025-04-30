import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TaskSortingService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  final String apiKey;

  TaskSortingService(this.apiKey);

  Future<List<String>> getYouTubeRecommendations(String task) async {
    final prompt =
        "Give me a list of the 5 most relevant, popular YouTube video URLs for the topic: \"$task\". "
        "Return only direct YouTube video links, one per line, no explanations.";
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "deepseek/deepseek-chat-v3-0324:free",
        "messages": [
          {
            "role": "user",
            "content": prompt
          }
        ],
        "max_tokens": 1000,
        "temperature": 0.3,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String links = data['choices'][0]['message']['content'];
      // Split into lines, remove empty
      return links
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.startsWith('http'))
          .toList();
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<String> sortTasksWithDeepSeek(List<Map<String, dynamic>> tasks) async {
    try {
      final taskDescriptions = tasks.map((task) =>
      '${task['task']} (Due: ${DateFormat('MMM dd').format(task['date'])} | Difficulty: ${task['difficulty']})'
      ).join('\n');

      final prompt =
          "Sort these tasks by priority considering both difficulty and due date. "
          "Harder tasks with closer due dates should come first. "
          "Return ONLY the original task names in priority order, one per line. "
          "Do not include dates or difficulties in the response. "
          "Here are the tasks:\n$taskDescriptions";

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "deepseek/deepseek-chat-v3-0324:free",
          "messages": [
            {
              "role": "user",
              "content": prompt
            }
          ],
          "max_tokens": 1000,
          "temperature": 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }
}