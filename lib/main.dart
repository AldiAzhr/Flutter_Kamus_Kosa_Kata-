import 'package:flutter/material.dart';
import 'dictionary_app.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kamus Kosa Kata',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DictionaryApp(),
      debugShowCheckedModeBanner: false, // Menonaktifkan teks debug
    );
  }
}
