import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF8BBD0),
          primary: const Color(0xFFF8BBD0),
          secondary: const Color(0xFFCE93D8),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
