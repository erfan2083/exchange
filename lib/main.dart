import 'package:flutter/material.dart';
import 'package:exchange/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nobitex Exchange',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Vazirmatn',
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
