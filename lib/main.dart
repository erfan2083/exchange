import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CryptoApp());
}

class CryptoApp extends StatelessWidget {
  const CryptoApp({super.key});

  Future<bool> _hasApiKey() async {
    final storage = FlutterSecureStorage();
    final key = await storage.read(key: 'api_key');
    return key != null && key.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nobitex Crypto App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: FutureBuilder<bool>(
        future: _hasApiKey(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          return snapshot.data! ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}
