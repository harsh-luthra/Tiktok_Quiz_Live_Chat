import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiktok_quiz_ui/questionObj.dart';
import 'dart:convert';

import 'CountdownPage.dart';

// Question Model


class QuizManagerPage extends StatefulWidget {
  @override
  _QuizManagerPageState createState() => _QuizManagerPageState();
}

class _QuizManagerPageState extends State<QuizManagerPage> {
  List<String> _quizNames = []; // List to store all saved quiz names

  List<Map<String, dynamic>> _quizNamesWithQuestionCount = [];

  // Map<String, int> _quizNamesWithQuestionCount = {
  //   'Quiz 1': 10,
  //   'Quiz 2': 15,
  //   'Quiz 3': 12,
  // };

  @override
  void initState() {
    super.initState();
    _loadQuizNames();
  }

  // Load quiz names from SharedPreferences
  // void _loadQuizNames() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final keys = prefs.getKeys();
  //   setState(() {
  //     _quizNames = keys.where((key) => key.isNotEmpty).toList(); // Ensure non-empty names
  //   });
  // }

  void _loadQuizNames() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    List<Map<String, dynamic>> quizListWithCount = [];

    for (var key in keys) {
      if (key.isNotEmpty) {
        final quizData = prefs.getString(key);

        if (quizData != null) {
          List<dynamic> quizList = jsonDecode(quizData);
          int questionCount = quizList.length;  // Counting the questions in the quiz

          quizListWithCount.add({
            'quizName': key,
            'questionCount': questionCount,
          });
        }
      }
    }

    setState(() {
      _quizNamesWithQuestionCount = quizListWithCount; // Updating the state with quiz names and question counts
    });
  }

  // Navigate to manage quiz page
  void _manageQuizzes([String? quizName]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageQuizzesPage(quizName: quizName),
      ),
    ).then((_) => _loadQuizNames()); // Refresh list after coming back
  }

  // void _manageQuizzes() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final keys = prefs.getKeys();
  //   final quizNames = keys.toList();
  //
  //   if (quizNames.isEmpty) {
  //     // No quizzes — go straight to add new quiz
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => ManageQuizzesPage(), // Will be blank initially
  //       ),
  //     );
  //     return;
  //   }
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Select Quiz to Edit'),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ...quizNames.map((quizName) => ListTile(
  //               title: Text(quizName),
  //               trailing: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   IconButton(
  //                     icon: Icon(Icons.edit),
  //                     onPressed: () {
  //                       Navigator.pop(context); // Close dialog
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (_) => ManageQuizzesPage(
  //                             quizNameToEdit: quizName,
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                   IconButton(
  //                     icon: Icon(Icons.delete, color: Colors.red),
  //                     onPressed: () => _deleteQuiz(quizName),
  //                   ),
  //                 ],
  //               ),
  //             )),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           child: Text('Add New Quiz'),
  //           onPressed: () {
  //             Navigator.pop(context); // Close dialog
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (_) => ManageQuizzesPage(),
  //               ),
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Build the main page UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Manager')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _showQuizListDialog,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.white, // Text color
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                elevation: 10, // Shadow for a floating effect
              ),
              child: Text(
                'Manage Quizzes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
            ),
            SizedBox(height: 20), // Space between buttons

            ElevatedButton(
              onPressed: _startQuiz,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.white, // Text color
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                elevation: 10, // Shadow for a floating effect
              ),
              child: Text(
                'Start Quiz',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show the list of quiz names
  void _showQuizListDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          _quizNamesWithQuestionCount.isEmpty
              ? 'No Quiz Found'
              : 'Select Quiz to Edit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: _quizNamesWithQuestionCount.isEmpty
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No quizzes available. Add a new one.',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              onPressed: () {
                Navigator.pop(ctx); // Close the dialog
                _manageQuizzes();    // Navigate to manage quiz
              },
              child: Text(
                'Add New Quiz',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        )
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loop through quiz list with enhanced UI
            for (var quizData in _quizNamesWithQuestionCount)
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple[900],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  title: Text(
                    quizData['quizName'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    'Questions: ${quizData['questionCount']}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _manageQuizzes(quizData['quizName']);
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _deleteQuiz(quizData['quizName']),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }


  // Delete a quiz from SharedPreferences
  void _deleteQuiz(String quizName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Quiz'),
        content: Text('Are you sure you want to delete "$quizName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(quizName);

      // Reload the quiz list
      setState(() {
        _quizNames.remove(quizName);
      });

      _loadQuizNames();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted quiz: $quizName')),
      );

      // If no quizzes remain, close the dialog
      if (_quizNames.isEmpty) {
        Navigator.of(context, rootNavigator: true).pop(); // Close dialog
      }
    }
  }

  // Start quiz logic (prompt for quiz selection)
  void _startQuiz() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Select Quiz For Starting',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 300,
                child: ListView.builder(
                  itemCount: _quizNamesWithQuestionCount.length,
                  itemBuilder: (context, index) {
                    // String quizName = _quizNamesWithQuestionCount.keys.elementAt(index);
                    // int questionCount = _quizNamesWithQuestionCount[quizName]!;

                    final quizData = _quizNamesWithQuestionCount[index];
                    final quizName = quizData['quizName'];
                    final questionCount = quizData['questionCount'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.deepPurple, backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black26,
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Return to the main page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CountdownPage(quizName: quizName),
                            ),
                          );
                        },
                        child: Text(
                          '$quizName - $questionCount questions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

class ManageQuizzesPage extends StatefulWidget {
  final String? quizName;

  ManageQuizzesPage({this.quizName});

  @override
  _ManageQuizzesPageState createState() => _ManageQuizzesPageState();
}

class _ManageQuizzesPageState extends State<ManageQuizzesPage> {
  List<Question> _questions = [];
  final _quizNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.quizName != null) {
      _quizNameController.text = widget.quizName!;
      _loadQuiz(widget.quizName!);
    }
  }

  // Load the quiz from SharedPreferences for editing
  void _loadQuiz(String quizName) async {
    final prefs = await SharedPreferences.getInstance();
    String? encoded = prefs.getString(quizName);
    if (encoded != null) {
      final List<dynamic> questionList = jsonDecode(encoded);
      setState(() {
        _questions = questionList.map((q) => Question.fromJson(q)).toList();
      });
    }
  }

  // Show dialog to add or edit a question
  void _showEditDialog({Question? question, int? index}) {
    final questionController = TextEditingController(text: question?.question);
    final answerController = TextEditingController(text: question?.answer);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(index == null ? 'Add Question' : 'Edit Question'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: questionController, decoration: InputDecoration(labelText: 'Question')),
            TextField(controller: answerController, decoration: InputDecoration(labelText: 'Answer')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (questionController.text.isNotEmpty && answerController.text.isNotEmpty) {
                final newQuestion = Question(
                  question: questionController.text,
                  answer: answerController.text,
                );
                setState(() {
                  if (index != null) {
                    _questions[index] = newQuestion; // Edit question
                  } else {
                    _questions.add(newQuestion); // Add question
                  }
                });
                Navigator.pop(ctx);
              }
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Delete question from the list
  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index); // Delete question
    });
  }

  // Save the quiz locally
  void _saveQuiz() async {
    final quizName = _quizNameController.text;
    if (quizName.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_questions.map((q) => q.toJson()).toList());
    await prefs.setString(quizName, encoded);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quiz Saved')));
    Navigator.pop(context); // Return to the main page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Quiz: ${widget.quizName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _quizNameController,
              decoration: InputDecoration(labelText: 'Quiz Name'),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () => _showEditDialog(), child: Text('Add Question')),
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _questions.removeAt(oldIndex);
                    _questions.insert(newIndex, item);
                  });
                },
                children: [
                  for (int i = 0; i < _questions.length; i++)
                    ListTile(
                      key: ValueKey('q$i'),
                      title: Text(_questions[i].question),
                      subtitle: Text(_questions[i].answer),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: Icon(Icons.edit), onPressed: () => _showEditDialog(question: _questions[i], index: i)),
                          IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteQuestion(i)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _saveQuiz,
              child: Text('Save Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
