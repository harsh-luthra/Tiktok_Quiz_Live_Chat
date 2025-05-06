import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiktok_quiz_ui/questionObj.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'chatMsgObj.dart';

// void main() => runApp(TikTokQuizApp());

// class TikTokQuizApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'TikTok Quiz System',
//       theme: ThemeData.dark(),
//       home: QuizScreen(),
//     );
//   }
// }

class QuizScreen extends StatefulWidget {
  final String quizName;
  QuizScreen({required this.quizName});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

final int pointsPerCorrect = 100;

final Map<String, LeaderboardEntry> _leaderboard = {};

class LeaderboardEntry {
  final String profileName;
  int score;

  LeaderboardEntry({required this.profileName, required this.score});
}

class _QuizScreenState extends State<QuizScreen> {
  late final StreamSubscription _wsSub;

  final _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8081'));
  final List<ChatMessage> _chatMessages = [];
  final Map<String, LeaderboardEntry> _leaderboard = {};
  // final List<Question> _questions = [
  //   Question(text: "Capital of France?", answer: "Paris"),
  //   Question(text: "2 + 2?", answer: "4"),
  //   Question(text: "Largest planet?", answer: "Jupiter"),
  // ];
  List<Question> _questions = [];

  int _currentQuestionIndex = 0;
  Question get _currentQuestion => _questions[_currentQuestionIndex];

  final int _defaultPerQuizTime = 15;

  int _secondsLeft = 15;

  bool _quizCompleted = false;

  Map<String, String> _firstCorrectAnswer = {}; // Tracks first correct user per question

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _audioPlayerChange = AudioPlayer();
  final AudioPlayer _audioPlayerChime = AudioPlayer();

  int _tickIndex = 0; // Will toggle between 0 and 1

  @override
  void initState() {
    super.initState();

    _loadQuizQuestions();

    _wsSub = _channel.stream.listen((message) {
      final data = jsonDecode(message);
      final chat = ChatMessage.fromJson(data);

      if (!mounted) return;
      setState(() => _chatMessages.insert(0, chat));
      _checkAnswer(chat);
    });

  }

  @override
  void dispose() {
    _wsSub.cancel(); // ✅ avoid memory leaks
    _channel.sink.close(); // optional: also close the connection
    super.dispose();
  }

  Future<void> playChange() async {
    await _audioPlayerChange.play(AssetSource('sounds/change.mp3'));
  }

  Future<void> playChime() async {
    await _audioPlayerChime.play(AssetSource('sounds/chime.mp3'));
  }

  Future<void> playAlternatingTick() async {
    final tickFiles = ['sounds/tick1.mp3', 'sounds/tick2.mp3'];
    final fileToPlay = tickFiles[_tickIndex];
    await _audioPlayer.play(AssetSource(fileToPlay));
    _tickIndex = (_tickIndex + 1) % tickFiles.length; // Toggle between 0 and 1
  }

  Future<void> _loadQuizQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final quizData = prefs.getString(widget.quizName);

    if (quizData != null) {
      List<dynamic> quizList = jsonDecode(quizData);
      print(quizList);
      setState(() {
        _questions = quizList
            .map((question) => Question.fromJson(Map<String, dynamic>.from(question)))
            .toList();
      });

      _startQuiz(); // Start the quiz after questions are loaded

    } else {
      // Handle case where the quiz name doesn't exist
      print('Quiz not found!');
    }
  }

  void _checkAnswer(ChatMessage chat) {
    // If quiz is completed, no more answers should be accepted.
    if (_quizCompleted) {
      return;
    }

    // Check if the current question has already been answered correctly
    if (_firstCorrectAnswer.containsKey(_currentQuestion.question)) {
      // If a correct answer already exists for this question, ignore subsequent correct answers
      return;
    }

    playChime();

    // Normalize user answer and correct answer to lower case to make comparison case-insensitive
    final userAnswer = chat.message.toLowerCase().trim();
    final correctAnswer = _currentQuestion.answer.toLowerCase().trim();

    // Check if the answer is correct
    // if (userAnswer == correctAnswer) {
      setState(() {
        // Mark this user as the first to answer correctly for this question
        _firstCorrectAnswer[_currentQuestion.question] = chat.userId;

        // Calculate extra points based on time left
        int extraPoints = _secondsLeft * 10; // 10 points per second left

        // Update leaderboard with points for the correct answer + extra points
        if (_leaderboard.containsKey(chat.userId)) {
          _leaderboard[chat.userId]!.score += pointsPerCorrect + extraPoints;
        } else {
          // If the user doesn't exist in the leaderboard, create a new entry with the extra points
          _leaderboard[chat.userId] = LeaderboardEntry(
            // profileName: "${chat.profileName}\n${chat.username}",
            profileName: chat.profileName,
            score: pointsPerCorrect + extraPoints,
          );
        }
      });
    // }
  }


  // void _checkAnswer(ChatMessage chat) {
  //   // Prevent duplicate correct answers for the current question
  //   if (_leaderboard.containsKey(chat.userId)) return;
  //
  //   final userAnswer = chat.message.toLowerCase().trim();
  //   final correctAnswer = _currentQuestion.answer.toLowerCase().trim();
  //
  //   if (userAnswer == correctAnswer) {
  //     setState(() {
  //       if (_leaderboard.containsKey(chat.userId)) {
  //         // Add points if already in leaderboard
  //         _leaderboard[chat.userId]!.score += pointsPerCorrect;
  //       } else {
  //         // First time correct, add to leaderboard
  //         _leaderboard[chat.userId] = LeaderboardEntry(
  //           profileName: chat.profileName,
  //           score: pointsPerCorrect,
  //         );
  //       }
  //     });
  //   }
  //
  //   //Just for testing LeaderBoard
  //   // setState(() {
  //   //   if (_leaderboard.containsKey(chat.userId)) {
  //   //     // Add points if already in leaderboard
  //   //     _leaderboard[chat.userId]!.score += pointsPerCorrect;
  //   //   } else {
  //   //     // First time correct, add to leaderboard
  //   //     _leaderboard[chat.userId] = LeaderboardEntry(
  //   //       profileName: chat.profileName,
  //   //       score: pointsPerCorrect,
  //   //     );
  //   //   }
  //   // });
  //
  // }

  void _startQuiz() async {
    for (var i = 0; i < _questions.length; i++) {
      if (!mounted) return; // Ensure widget is still mounted

      // Update question index and reset leaderboard before each question
      setState(() {
        _currentQuestionIndex = i;
        // _leaderboard.clear();
        _secondsLeft = _defaultPerQuizTime; // Reset timer for each new question
      });

      // Timer countdown logic for each question
      for (var sec = _defaultPerQuizTime; sec >= 0; sec--) {
        if (!mounted) return; // Ensure widget is still mounted before updating UI

        setState(() {
          _secondsLeft = sec; // Update timer
        });

        playAlternatingTick();

        await Future.delayed(Duration(seconds: 1)); // Delay 1 second between each countdown

      }

      await playChange();
      await Future.delayed(Duration(seconds: 1));

    }

    if (!mounted) return;
    setState(() {
      _quizCompleted = true;
      // _currentQuestionIndex = 0; // Optionally reset to the first question after completion
    });

    // After the quiz ends, reset everything to show the first question
    // if (!mounted) return;
    // setState(() {
    //   _currentQuestionIndex = 0; // Reset to first question
    //   _leaderboard.clear();
    // });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("TikTok Quiz")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("TikTok Quiz"),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Question & Leaderboard
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(16),
                  width: double.infinity, // Takes full available width
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question progress text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Question counter
                          Text(
                            _quizCompleted
                                ? "Quiz Completed"
                                : "Question ${_currentQuestionIndex + 1} of ${_questions.length}",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),

                          // Timer
                          _quizCompleted ? Icon(Icons.check_circle, size: 20, color: Colors.green) :
                          Row(
                            children: [
                              Icon(Icons.timer, size: 20, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                "${_secondsLeft}s",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Full-width black card with centered white text
                      _quizCompleted ?
                      Text(
                        "See Winners Below !",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      )
                      : Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              _currentQuestion.question,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(12),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("🏆 Leaderboard", textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _leaderboard.length,
                            itemBuilder: (context, index) {
                              final sortedEntries = _leaderboard.entries.toList()
                                ..sort((a, b) => b.value.score.compareTo(a.value.score));

                              final entry = sortedEntries[index];
                              final rank = index + 1;

                              IconData rankIcon;
                              Color rankColor;

                              switch (rank) {
                                case 1:
                                  rankIcon = Icons.emoji_events;
                                  rankColor = Colors.amber;
                                  break;
                                case 2:
                                  rankIcon = Icons.emoji_events;
                                  rankColor = Colors.grey;
                                  break;
                                case 3:
                                  rankIcon = Icons.emoji_events;
                                  rankColor = Colors.brown;
                                  break;
                                default:
                                  rankIcon = Icons.star_border;
                                  rankColor = Colors.white60;
                              }

                              return ListTile(
                                leading: Icon(rankIcon, color: rankColor),
                                title: Text(
                                  entry.value.profileName,
                                  style: TextStyle(
                                    color: rankColor,
                                    fontWeight:
                                    rank <= 3 ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                trailing: Text(
                                  "${entry.value.score} pts",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Live Chat
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  color: Colors.indigo,
                  child: Text(
                    "💬 Live Chat",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(12),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      reverse: true,
                      itemCount: _chatMessages.length,
                      itemBuilder: (context, index) {
                        final chat = _chatMessages[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            dense: true,
                            title: Text(chat.profileName, style: TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text(chat.message),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
