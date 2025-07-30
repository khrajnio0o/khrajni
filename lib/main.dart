import 'package:flutter/material.dart';
import 'package:khrajni/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _selectedLanguage = 'ar'; // Default language

  void updateLanguage(String newLanguage) {
    setState(() {
      _selectedLanguage = newLanguage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'خرجني',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Tajawal',
      ),
      home: HomeScreen(
        selectedLanguage: _selectedLanguage,
        updateLanguage: updateLanguage,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
