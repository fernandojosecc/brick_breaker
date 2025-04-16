import 'package:flutter/material.dart';
import 'dart:async' as async;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //ball variables
  double ballX = 0;
  double ballY = 0;

  void startGame() {
    async.Timer.periodic(Duration(milliseconds: 10), (timer) {
      setState(() {
        ballY -= 0.01;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: startGame,
      child: Scaffold(
        backgroundColor: Colors.deepPurple[100],
        body: Center(
          child: Stack(
            children: [
              //tap to play
              Container(
                alignment: Alignment(0, -0.2),
                child: Text(
                  'Tap to play',
                  style: TextStyle(color: Colors.deepPurple[400]),
                ),
              ),

              //ball
              Container(
                alignment: Alignment(ballX, ballY),
                child: Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
