import 'dart:convert';
import 'dart:io'; // Import for HttpClient
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart'; // Import for IOCient

class DevelopmentHttpClient extends http.BaseClient {
  final IOClient _ioClient;
  final String _trustedHost;

  DevelopmentHttpClient(this._trustedHost)
    : _ioClient = IOClient(
        HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) =>
                  host == _trustedHost,
      );

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _ioClient.send(request);
  }
}

class ApiService {
  final String baseUrl = 'https://192.168.1.75:8000';
  late final http.Client _httpClient;

  ApiService() {
    // Use custom client for development to allow self-signed certs
    _httpClient = DevelopmentHttpClient(Uri.parse(baseUrl).host);
  }

  // Dispose the client when the service is no longer needed
  void dispose() {
    _httpClient.close();
  }

  Future<List<String>> fetchCategories() async {
    final response = await _httpClient.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Map<String, dynamic>> reframeThought(String thought) async {
    final response = await _httpClient.post(
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

  Future<Map<String, dynamic>> saveJournalEntry(
    String originalThought,
    String suggestion,
    String tag,
  ) async {
    final response = await _httpClient.post(
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

  Future<List<dynamic>> getEntries() async {
    final response = await _httpClient.get(Uri.parse('$baseUrl/entries'));
    if (response.statusCode == 200) {
      // The backend returns a list of dictionaries (JSON objects)
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load journal entries: ${response.body}');
    }
  }

  Future<String> fetchSosTechnique({String? feeling}) async {
    String url = '$baseUrl/sos';
    if (feeling != null && feeling.isNotEmpty) {
      url += '?feeling=${Uri.encodeComponent(feeling)}';
    }
    final response = await _httpClient.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to fetch SOS technique: ${response.body}');
    }
  }
}
