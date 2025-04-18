import 'package:brick_breaker/ball.dart';
import 'package:brick_breaker/brick.dart';
import 'package:brick_breaker/coverscreen.dart';
import 'package:brick_breaker/gameoverscreen.dart';
import 'package:brick_breaker/player.dart';
import 'package:flutter/material.dart';
import 'dart:async' as async;

import 'package:flutter/services.dart';

enum direction { UP, DOWN, LEFT, RIGHT }

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
  double ballXincrements = 0.01;
  double ballYincrements = 0.01;
  var ballYDirection = direction.DOWN;
  var ballXDirection = direction.LEFT;

  //player variables
  double playerX = -0.2;
  double playerWidth = 0.4; //out of 2

  //brick variables
  static double firstBrickX = -0.5;
  static double firstBrickY = -0.9;
  static double brickWidth = 0.4; //out of 2
  static double brickHeight = 0.05; //out of 2
  bool brickBroken = false;

  static var MyBricks = [
    //[x,y, broken = true/flase]
    [firstBrickX, firstBrickY, false],
  ];

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

      //Check if brick is hit
      checkForBrokenBricks();
    });
  }

  void checkForBrokenBricks() {
    //checks for when ball hits bottom of brick
    if (ballX >= MyBricks[0][0] &&
        ballX <= brickX + brickWidth &&
        ballY <= brickY + brickHeight &&
        brickBroken == false) {
      setState(() {
        brickBroken = true;
        ballYDirection = direction.DOWN;
      });
    }
  }

  //is player dead
  bool isPlayerDead() {
    //player dies if ball reaches the bottom of the screen
    if (ballY >= 1) {
      return true;
    }
    return false;
  }

  //move ball
  void moveBall() {
    setState(() {
      //Move horizontally
      if (ballXDirection == direction.LEFT) {
        ballX -= ballXincrements;
      } else if (ballXDirection == direction.RIGHT) {
        ballX += ballXincrements;
      }

      //move vertically
      if (ballYDirection == direction.DOWN) {
        ballY += ballYincrements;
      } else if (ballYDirection == direction.UP) {
        ballY -= ballYincrements;
      }
    });
  }

  //update direction of the ball
  void updateDirection() {
    setState(() {
      //ball goes up when it hits player
      if (ballY >= 0.9 && ballX >= playerX && ballX <= playerX + playerWidth) {
        ballYDirection = direction.UP;
      }
      //ball goes down when it hits the top of screen
      else if (ballY <= -1) {
        ballYDirection = direction.DOWN;
      }

      //ball goes left when it hits right wall
      if (ballX >= 1) {
        ballXDirection = direction.LEFT;
      }
      //ball goes right when it hits left wall
      else if (ballX <= -1) {
        ballXDirection = direction.RIGHT;
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

                //game over screen
                GameOverScreen(isGameOver: isGameOver),

                //ball
                MyBall(ballX: ballX, ballY: ballY),

                //player
                MyPlayer(playerX: playerX, playerWidth: playerWidth),

                //bricks
                MyBrick(
                  brickX: brickX,
                  brickY: brickY,
                  brickWidth: brickWidth,
                  brickHeight: brickHeight,
                  brickBroken: brickBroken,
                ),
                //Where is playerX exactly?
              ],
            ),
          ),
        ),
      ),
    );
  }
}
