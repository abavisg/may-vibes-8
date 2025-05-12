import 'package:flutter/material.dart';
import 'package:mobile/models/reframe_response.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/widgets/thought_form.dart';
import 'dart:developer'; // Import for logging
import 'package:mobile/screens/journal_screen.dart'; // Import for navigation

class ReframeScreen extends StatefulWidget {
  const ReframeScreen({super.key});

  @override
  ReframeScreenState createState() => ReframeScreenState();
}

class ReframeScreenState extends State<ReframeScreen> {
  final ApiService _apiService = ApiService();

  List<String> _categories = [];
  bool _isLoadingCategories = false;
  String? _categoriesError;

  bool _isReframing = false;
  String? _reframeError;
  ReframeResponse? _reframeResult;
  String? _originalThought;
  String? _selectedReframedSuggestion;
  String? _userSelectedTag; // Tag can be changed by the user

  bool _isSaving = false;
  String? _saveError;
  String? _saveSuccessMessage;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });
    try {
      final categories = await _apiService.fetchCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      setState(() {
        _categoriesError = 'Failed to load categories: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _reframeThought(String thought, String? initialTag) async {
    setState(() {
      _isReframing = true;
      _reframeError = null;
      _reframeResult = null;
      _originalThought = thought;
      _selectedReframedSuggestion = null;
      _userSelectedTag =
          initialTag; // Initialize with tag from LLM if available
      _saveSuccessMessage = null; // Clear previous save messages
    });

    try {
      final result = await _apiService.reframeThought(thought);
      final reframeResponse = ReframeResponse.fromJson(result);
      setState(() {
        _reframeResult = reframeResponse;
        // Auto-select the first suggestion or handle based on UI design
        if (reframeResponse.suggestions.isNotEmpty) {
          _selectedReframedSuggestion = reframeResponse.suggestions[0];
        }
        // Use the tag from the reframe result, allow user to change it later
        _userSelectedTag = reframeResponse.tag;
      });
    } catch (e) {
      setState(() {
        _reframeError = 'Failed to reframe thought: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isReframing = false;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (_originalThought == null ||
        _selectedReframedSuggestion == null ||
        _userSelectedTag == null) {
      // Should not happen if UI flow is correct, but good defensive check
      log(
        "Cannot save: missing thought, suggestion, or tag.",
        name: 'ReframeScreen',
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
      _saveSuccessMessage = null;
    });

    try {
      await _apiService.saveJournalEntry(
        _originalThought!,
        _selectedReframedSuggestion!,
        _userSelectedTag!,
      );
      setState(() {
        _saveSuccessMessage = 'Thought saved successfully!';
        _reframeResult = null;
        _originalThought = null;
        _selectedReframedSuggestion = null;
        _userSelectedTag = null;
      });
    } catch (e) {
      setState(() {
        _saveError = 'Failed to save thought: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoadingCategories) {
      content = Center(child: CircularProgressIndicator());
    } else if (_categoriesError != null) {
      content = Center(child: Text(_categoriesError!));
    } else {
      content = SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ThoughtForm(
              categories: _categories,
              onSubmit: (thought, selectedCategory) {
                // Note: The category selected here is from the initial form
                // We will use the tag from the LLM result first, then allow changing
                _reframeThought(
                  thought,
                  selectedCategory,
                ); // Pass initial category to reframe (optional for now)
              },
            ),
            SizedBox(height: 24),
            if (_isReframing) CircularProgressIndicator(),
            if (_reframeError != null)
              Text(_reframeError!, style: TextStyle(color: Colors.red)),
            if (_reframeResult != null) ...[
              Text(
                'Reframing Suggestions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              // Display suggestions - allow user to select one if multiple
              // For simplicity, let's just display them and auto-select the first one for saving
              ..._reframeResult!.suggestions.map(
                (suggestion) => Text('- $suggestion'),
              ),
              SizedBox(height: 16),
              Text(
                'Auto-generated Tag:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              // Allow user to change the tag using a dropdown with the fetched categories
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Category to Save',
                ),
                value:
                    _userSelectedTag, // Use the state variable for the selected tag
                onChanged: (String? newValue) {
                  setState(() {
                    _userSelectedTag = newValue;
                  });
                },
                items:
                    _categories.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    _isSaving
                        ? null
                        : _saveEntry, // Disable button while saving
                child:
                    _isSaving
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Save Journal Entry'),
              ),
              if (_saveError != null)
                Text(_saveError!, style: TextStyle(color: Colors.red)),
              if (_saveSuccessMessage != null)
                Text(
                  _saveSuccessMessage!,
                  style: TextStyle(color: Colors.green),
                ),
            ],
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('MindFlip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.book_outlined), // Journal icon
            onPressed: () {
              // Navigate to the JournalScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JournalScreen()),
              );
            },
          ),
        ],
      ),
      body: content,
    );
  }
}
