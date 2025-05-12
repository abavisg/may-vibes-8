import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://localhost:8000';

  Future<List<String>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Map<String, dynamic>> reframeThought(String thought) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reframe'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'thought': thought}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to reframe thought: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> saveJournalEntry(String originalThought, String suggestion, String tag) async {
    final response = await http.post(
      Uri.parse('$baseUrl/entries'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'original_thought': originalThought,
        'suggestion': suggestion,
        'tag': tag,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to save journal entry: ${response.body}');
    }
  }
} 