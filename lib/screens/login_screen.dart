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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF121330), // top color
            Color(0xFF3E1E68), // bottom color
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Login to Nobitex', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.transparent),
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('Enter your Nobitex API Key:', style: TextStyle(fontSize: 24, color: Colors.white)),
              const SizedBox(height: 60),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "API Key",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none, // No border line
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isSaving ? null : _saveApiKey,
                child: isSaving ? const CircularProgressIndicator() : const Text('Save and Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
