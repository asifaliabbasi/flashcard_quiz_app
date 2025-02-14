import 'dart:ffi';

import 'package:flashcard_quiz_app/model/database_helper.dart';
import 'package:flashcard_quiz_app/widgets/score_Board.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> _quizFlashcards = [];
  int _currentIndex = 0;
  int _score = 0;
  TextEditingController _answerController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizFlashcards();
  }

  Future<void> _loadQuizFlashcards() async {
    final data = await DatabaseHelper.instance
        .getRandomFlashcards(5); // Load 5 random questions
    setState(() {
      _quizFlashcards = data;
      _isLoading = false;
    });
  }

  void _checkAnswer() {
    String userAnswer = _answerController.text.trim().toLowerCase();
    String correctAnswer = _quizFlashcards[_currentIndex]['answer'].trim().toLowerCase();
    if (userAnswer.isNotEmpty) {
      if (userAnswer == correctAnswer) {
        _score++;
      }
    }
  }

  void _showResult() async {
    await DatabaseHelper.instance.saveScore(_score, _quizFlashcards.length);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quiz Finished!'),
        content: Text('Your score: $_score / ${_quizFlashcards.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Quiz Mode',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ScoreBoard(),));
          }, child: Text('ScoreBoard',style: TextStyle(color: Colors.green),))
        ],
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Score Display
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Your Score: $_score',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                SizedBox(height: 40),

                // Question Box
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.purpleAccent],
                    ),
                  ),
                  child: Text(
                    '${_quizFlashcards[_currentIndex]['question']}?',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 30),

                // Answer Input
                TextField(
                  controller: _answerController,
                  decoration: InputDecoration(
                    hintText: 'Your Answer',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 30),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_currentIndex > 0) {
                          setState(() {
                            _currentIndex--;
                            _answerController.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Back',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentIndex < _quizFlashcards.length - 1) {
                          setState(() {
                            _currentIndex++;
                            _answerController.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Skip',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: (){
                     if (_answerController.text.isNotEmpty && _currentIndex < _quizFlashcards.length -1) {
                         _checkAnswer();
                         _currentIndex++;
                         setState(() {
                           _answerController.clear();
                           });
                       }
                     else if(_currentIndex == _quizFlashcards.length-1){
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                         content: Text('Questions Ended Submit Your Quiz'),
                         elevation: 3,
                         behavior: SnackBarBehavior.floating,
                         backgroundColor: Colors.blueAccent,
                       ));
                     }
                       else {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                           content: Text('Answer Please'),
                           elevation: 3,
                           behavior: SnackBarBehavior.floating,
                           backgroundColor: Colors.blueAccent,
                         ));
                     } },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade700,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Next',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white))
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                ElevatedButton(
                  onPressed: () {
                    if(_currentIndex < _quizFlashcards.length) {
                    setState(() {
                    _showResult();
                    });}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Submit',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(onPressed: (){
        setState(() {
          _score = 0;
          _currentIndex = 0;
        });
      }, child: Text('Restart Quiz')),
    );
  }
}
