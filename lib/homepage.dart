import 'package:brick_breaker/ball.dart';
import 'package:brick_breaker/coverscreen.dart';
import 'package:brick_breaker/player.dart';
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

  //player variables
  double playerX = 0;
  double playerWidth = 0.3; //out of 2

  //game settings
  bool hasGameStarted = false;

  void startGame() {
    hasGameStarted = true;
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
              CoverScreen(hasGameStarted: hasGameStarted),

              //ball
              MyBall(ballX: ballX, ballY: ballY),

              //player
              MyPlayer(playerX: playerX, playerWidth: playerWidth),
            ],
          ),
        ),
      ),
    );
  }
}
