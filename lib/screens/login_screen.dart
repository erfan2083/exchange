import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  final storage = const FlutterSecureStorage();
  bool isSaving = false;

  void _saveApiKey() async {
    final apiKey = _controller.text.trim();
    if (apiKey.isEmpty) return;

    setState(() => isSaving = true);
    await storage.write(key: 'api_key', value: apiKey);
    setState(() => isSaving = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login to Nobitex')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Enter your Nobitex API Key:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'API Key'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSaving ? null : _saveApiKey,
              child: isSaving ? const CircularProgressIndicator() : const Text('Save and Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
