import 'package:brick_breaker/ball.dart';
import 'package:brick_breaker/coverscreen.dart';
import 'package:brick_breaker/player.dart';
import 'package:flutter/material.dart';
import 'dart:async' as async;

import 'package:flutter/services.dart';

enum direction { UP, DOWN }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  //ball variables
  double ballX = 0;
  double ballY = 0;
  var ballDirection = direction.DOWN;

  //player variables
  double playerX = -0.2;
  double playerWidth = 0.4; //out of 2

  //game settings
  bool hasGameStarted = false;
  bool isGameOver = false;

  void startGame() {
    hasGameStarted = true;
    async.Timer.periodic(Duration(milliseconds: 10), (timer) {
      //update direction
      updateDirection();

      //move ball
      moveBall();

      // check if player dead
      if (isPlayerDead()) {
        timer.cancel();
        isGameOver = true;
      }
    });
  }

  bool isPlayerDead() {
    if (ballY >= 1) {
      return true;
    }

    return false;
  }

  void moveBall() {
    setState(() {
      if (ballDirection == direction.DOWN) {
        ballY += 0.01;
      } else if (ballDirection == direction.UP) {
        ballY -= 0.01;
      }
    });
  }

  //update direction of the ball
  void updateDirection() {
    setState(() {
      if (ballY >= 0.9 && ballX >= playerX && ballX <= playerX + playerWidth) {
        ballDirection = direction.UP;
      } else if (ballY <= -0.9) {
        ballDirection = direction.DOWN;
      }
    });
  }

  //move player left
  void moveLeft() {
    setState(() {
      //only move left if moving left doesnt move player off the screen
      playerX = (playerX - 0.2).clamp(
        -1.0 + playerWidth / 2,
        1.0 - playerWidth / 2,
      );
    });
  }

  //move player right
  void moveRight() {
    //only move right if moving left doesnt move player off the screen
    setState(() {
      playerX = (playerX + 0.2).clamp(
        -1.0 + playerWidth / 2,
        1.0 - playerWidth / 2,
      ); //it prevents player to go beyond the right edge of the screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          print('Key pressed: ${event.logicalKey}');
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            moveLeft();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            moveRight();
          }
        }
      },
      child: GestureDetector(
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

                //Where is playerX exactly?
              ],
            ),
          ),
        ),
      ),
    );
  }
}
