import 'package:flutter/material.dart';
import 'package:tiktok_quiz_ui/TikTokQuizApp.dart';
import 'package:tiktok_quiz_ui/test.dart';

import 'QuizManagerPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TikTok Quiz System',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home:  QuizManagerPage(),
    );
  }
}