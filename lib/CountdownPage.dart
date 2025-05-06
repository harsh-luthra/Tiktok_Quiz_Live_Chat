import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'TikTokQuizApp.dart';

class CountdownPage extends StatefulWidget {
  final String quizName;
  CountdownPage({required this.quizName});

  @override
  _CountdownPageState createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  int _seconds = 2;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    final prefs = await SharedPreferences.getInstance();
    final quizData = prefs.getString(widget.quizName);
    final decoded = quizData != null ? jsonDecode(quizData) : [];

    if (decoded.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Quiz '${widget.quizName}' has no questions.")),
        );
        Navigator.pop(context); // Return to previous screen
      }
      return;
    }

    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _seconds--);
      if (_seconds <= 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(quizName: widget.quizName),
          ),
        );
        return false;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          _seconds > 0 ? 'Starting in $_seconds...' : 'Starting Quiz!',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
