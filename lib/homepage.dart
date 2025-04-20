import 'package:brick_breaker/ball.dart';
import 'package:brick_breaker/brick.dart';
import 'package:brick_breaker/coverscreen.dart';
import 'package:brick_breaker/gameoverscreen.dart';
import 'package:brick_breaker/player.dart';
import 'package:flutter/material.dart';
import 'dart:async' as async;
import 'dart:math';

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
    generateGridBricks();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  //ball variables
  double ballX = 0;
  double ballY = 0;
  double ballXincrements = 0.02;
  double ballYincrements = 0.01;
  var ballYDirection = direction.DOWN;
  var ballXDirection = direction.LEFT;

  //player variables
  double playerX = -0.2;
  double playerWidth = 0.4; //out of 2

  static const int columns = 6;
  static const int rows = 4;

  //brick variables
  static double firstBrickX = -0.5;
  static double firstBrickY = -0.9;
  static const double brickWidth = 0.3; // out of 2
  static const double brickHeight = 0.05;
  static const double brickGap = 0.05; // gap between bricks
  static int numberOfBricksInRow = 4;
  static double wallGap =
      0.5 *
      (2 -
          numberOfBricksInRow * brickWidth -
          (numberOfBricksInRow - 1) * brickGap);
  bool brickBroken = false;

  List<List<dynamic>> MyBricks = [];
  void generateGridBricks() {
    MyBricks.clear();
    Random rand = Random(); // for random jitter

    double startX = -1 + brickGap; // left boundary
    double startY = -0.9; // top boundary

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        double x = startX + col * (brickWidth + brickGap);

        // Tiny random vertical offset to break uniformity
        double y =
            startY +
            row * (brickHeight + brickGap) +
            (rand.nextDouble() * 0.01);

        // Avoid bricks going past the screen edge
        if (x + brickWidth <= 1) {
          MyBricks.add([x, y, false]);
        }
      }
    }
  }

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
    for (int i = 0; i < MyBricks.length; i++) {
      double brickX = MyBricks[i][0];
      double brickY = MyBricks[i][1];
      bool brickBroken = MyBricks[i][2];

      if (!brickBroken &&
          ballX >= brickX &&
          ballX <= brickX + brickWidth &&
          ballY >= brickY &&
          ballY <= brickY + brickHeight) {
        setState(() {
          MyBricks[i][2] = true;

          // Calculate distance from each side
          double leftDist = (brickX - ballX).abs();
          double rightDist = (brickX + brickWidth - ballX).abs();
          double topDist = (brickY - ballY).abs();
          double bottomDist = (brickY + brickHeight - ballY).abs();

          String sideHit = findMinSide(
            leftDist,
            rightDist,
            topDist,
            bottomDist,
          );

          // Change ball direction based on side hit
          if (sideHit == 'left') {
            ballXDirection = direction.LEFT;
          } else if (sideHit == 'right') {
            ballXDirection = direction.RIGHT;
          } else if (sideHit == 'top') {
            ballYDirection = direction.UP;
          } else if (sideHit == 'bottom') {
            ballYDirection = direction.DOWN;
          }
        });

        // Break only one brick per frame
        break;
      }
    }
  }

  //returns the smallest side
  String findMinSide(double left, double right, double top, double bottom) {
    double min = left;
    String side = 'left';

    if (right < min) {
      min = right;
      side = 'right';
    }
    if (top < min) {
      min = top;
      side = 'top';
    }
    if (bottom < min) {
      min = bottom;
      side = 'bottom';
    }

    return side;
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
      // 🎯 Fix paddle collision logic
      double playerLeftEdge = playerX - playerWidth / 2;
      double playerRightEdge = playerX + playerWidth / 2;

      if (ballY >= 0.9 && ballX >= playerLeftEdge && ballX <= playerRightEdge) {
        ballYDirection = direction.UP;
      }
      // Top of screen
      else if (ballY <= -1) {
        ballYDirection = direction.DOWN;
      }

      // Right wall
      if (ballX >= 1) {
        ballXDirection = direction.LEFT;
      }
      // Left wall
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

  //reset game back to initial values vhen user hits play again
  void resetGame() {
    setState(() {
      playerX = -0.2;
      ballX = 0;
      ballY = 0;
      isGameOver = false;
      hasGameStarted = false;
      generateGridBricks();
    });
  }

  void generateRandomBricks() {
    MyBricks.clear(); // remove old ones
    Random rand = Random();

    for (int i = 0; i < 24; i++) {
      double randomX = -1 + rand.nextDouble() * 2; // from -1 to 1
      double randomY =
          -0.9 + rand.nextDouble() * 0.8; // upper half screen (-0.9 to -0.1)

      MyBricks.add([randomX, randomY, false]);
    }
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
                CoverScreen(
                  hasGameStarted: hasGameStarted,
                  isGameOver: isGameOver,
                ),
                GameOverScreen(isGameOver: isGameOver, function: resetGame),
                MyBall(ballX: ballX, ballY: ballY),
                MyPlayer(playerX: playerX, playerWidth: playerWidth),

                // 💥 Dynamically show all bricks
                ...MyBricks.map((brick) {
                  return MyBrick(
                    brickX: brick[0],
                    brickY: brick[1],
                    brickBroken: brick[2],
                    brickWidth: brickWidth,
                    brickHeight: brickHeight,
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
