import 'package:flutter/material.dart';
import 'package:mindflip/models/journal_entry.dart';
import 'package:mindflip/services/api_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  JournalScreenState createState() => JournalScreenState();
}

class JournalScreenState extends State<JournalScreen> {
  final ApiService _apiService = ApiService();
  List<JournalEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  Future<void> _fetchEntries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _apiService.getEntries();
      setState(() {
        // Map the list of dictionaries to a list of JournalEntry objects
        _entries =
            data.map((entryJson) => JournalEntry.fromJson(entryJson)).toList();
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load journal entries: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MindFlip Journal')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Error: $_error'))
              : _entries.isEmpty
              ? const Center(child: Text('No journal entries yet.'))
              : ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: ListTile(
                      title: Text(
                        entry.originalThought,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4.0),
                          Text('Reframed: ${entry.reframedText}'),
                          const SizedBox(height: 4.0),
                          Text('Category: ${entry.category}'),
                          const SizedBox(height: 4.0),
                          Text(
                            'Saved: ${entry.createdAt.toLocal().toString().split('.')[0]}',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
