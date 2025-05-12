import 'package:flutter/material.dart';

class ThoughtForm extends StatefulWidget {
  final List<String> categories;
  final Function(String thought, String? selectedCategory) onSubmit;

  const ThoughtForm({
    super.key,
    required this.categories,
    required this.onSubmit,
  });

  @override
  ThoughtFormState createState() => ThoughtFormState();
}

class ThoughtFormState extends State<ThoughtForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _thoughtController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _thoughtController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_thoughtController.text, _selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _thoughtController,
            decoration: InputDecoration(
              labelText: 'Enter your negative thought',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a thought';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Category (Optional)',
            ),
            value: _selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
            items:
                widget.categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
          ),
          SizedBox(height: 24),
          ElevatedButton(onPressed: _submit, child: Text('Reframe Thought')),
        ],
      ),
    );
  }
}
