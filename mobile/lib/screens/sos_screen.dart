import 'package:flutter/material.dart';
import 'package:mobile/services/api_service.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  String _technique = 'Fetching technique...';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTechnique();
  }

  Future<void> _fetchTechnique() async {
    try {
      final apiService = ApiService();
      // We could potentially pass a feeling from the previous screen here,
      // but for simplicity, let's just get a general technique for now.
      final technique = await apiService.fetchSosTechnique();
      setState(() {
        _technique = technique;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load technique: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOS Technique')),
      body: Center(
        child:
            _isLoading
                ? const CircularProgressIndicator()
                : _error != null
                ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _technique,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
      ),
    );
  }
}
