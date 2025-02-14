import 'package:flutter/material.dart';
import '../model/database_helper.dart';

class ScoreBoard extends StatefulWidget {
  const ScoreBoard({super.key});

  @override
  State<ScoreBoard> createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadScores();
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
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("image/Boardbackground.jpg"),
              // Add this image to assets
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 20,),
             Row(
               children: [
                 BackButton(color: Colors.white,),
                 SizedBox(width: 65,),
                 Text(textAlign: TextAlign.center,
                     'Quiz ScoreBoard',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white,fontSize: 25)),
               ],
             ),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: _scores.length,
                  itemBuilder: (context, index) {
                    final score = _scores[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 6,
                      color: Colors.brown[300],
                      // Light brown color for wooden effect
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: score['score'] == score['total']
                              ? Colors.green
                              : Colors.blue,
                          child: Text(
                            "${index+1}",
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          'Score: ${score['score']} / ${score['total']}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight
                              .bold, color: Colors.white),
                        ),
                        subtitle: Text(
                          'Date: ${DateTime.parse(score['date'])
                              .toLocal()
                              .toString()
                              .split('.')[0]}',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        trailing: Icon(
                          score['score'] == score['total']
                              ? Icons.emoji_events
                              : Icons.star,
                          color: score['score'] == score['total']
                              ? Colors.orange
                              : Colors.yellowAccent,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () async {
                  await DatabaseHelper.instance.clearScores();
                  setState(() {
                    _loadScores();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Scores cleared successfully!")));
                    _scores.clear(); // Clear the local list as well
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Clear Scores', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }
}