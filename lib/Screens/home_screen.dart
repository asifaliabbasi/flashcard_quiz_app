import 'package:flashcard_quiz_app/Screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../model/database_helper.dart';

class FlashcardHomePage extends StatefulWidget {
  @override
  _FlashcardHomePageState createState() => _FlashcardHomePageState();
}

class _FlashcardHomePageState extends State<FlashcardHomePage> {
  List<Map<String, dynamic>> _flashcards = [];

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
    _loadScores();
  }

  Future<void> _loadFlashcards() async {
    final List<Map<String, dynamic>> data =
        await DatabaseHelper.instance.getFlashcards();
    if (mounted) {
      setState(() {
        _flashcards = data;
      });
    }
  }
  Future<void> _addFlashcard(String question, String answer) async {
    await DatabaseHelper.instance.addFlashcard(question, answer);
    await _loadFlashcards(); // Ensure flashcards reload after adding a new one
  }
  List<Map<String, dynamic>> _scores = [];

  Future<void> _loadScores() async {
    final scores = await DatabaseHelper.instance.getScores();
    setState(() {
      _scores = scores;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Flashcard Quiz', style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold,color: Colors.white)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          _flashcards.length == 0 ? Center(child: Text('Please Add Questions',style: TextStyle(color: Colors.white,fontSize: 35),)):
          Column(
            children: [
              SizedBox(height: 100), // Push content down from the AppBar
              // Glassmorphic Scoreboard
              Expanded(
                child: ListView.builder(
                  itemCount:_flashcards.length,
                  itemBuilder: (context, index) {
                    final flashcard= _flashcards[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GlassContainer(
                        blur: 15,
                        shadowStrength: 5,
                        opacity: 0.2,
                        borderRadius: BorderRadius.circular(20),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: CircleAvatar(
                            child: Text(
                              "${index+1}",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                           flashcard['question'],
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          subtitle: Text(
                            flashcard['answer'],
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Neumorphic Start Quiz Button
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(),));
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                child: Text(
                  "Start Quiz",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ],
      ),
        floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
    onPressed: () {
    showDialog(
    context: context,
    builder: (context) {
    TextEditingController questionController = TextEditingController();
    TextEditingController answerController = TextEditingController();
    return AlertDialog(
      elevation: 5,
    title: Text('Add Flashcard'),
    content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    TextField(controller: questionController, decoration: InputDecoration(labelText: 'Question')),
    TextField(controller: answerController, decoration: InputDecoration(labelText: 'Answer')),
    ],
    ),
    actions: [
    TextButton(
    child: Text('Cancel'),
    onPressed: () => Navigator.of(context).pop(),
    ),
    TextButton(
    child: Text('Add'),
    onPressed: () {
    _addFlashcard(questionController.text, answerController.text);
    Navigator.of(context).pop();
    setState(() {

    });
    },
    ),
    ],
    );
    },
    );
    }));
  }
}
