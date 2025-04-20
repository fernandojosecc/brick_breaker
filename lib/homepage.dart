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
    generateRandomBricks(); // 💥 for initial start
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

  //brick variables
  static double firstBrickX = -0.5;
  static double firstBrickY = -0.9;
  static double brickWidth = 0.4; //out of 2
  static double brickHeight = 0.05; //out of 2
  static double brickGap = 0.2;
  static int numberOfBricksInRow = 4;
  static double wallGap =
      0.5 *
      (2 -
          numberOfBricksInRow * brickWidth -
          (numberOfBricksInRow - 1) * brickGap);
  bool brickBroken = false;

  List<List<dynamic>> MyBricks = [
    //[x,y, broken = true/flase]
    [firstBrickX + 0 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 1 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 2 * (brickWidth + brickGap), firstBrickY, false],
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
    for (int i = 0; i < MyBricks.length; i++) {
      if (ballX >= MyBricks[i][0] &&
          ballX <= MyBricks[i][0] + brickWidth &&
          ballY <= MyBricks[i][1] + brickHeight &&
          MyBricks[i][2] == false) {
        setState(() {
          MyBricks[i][2] = true;

          //since brick is broken,
          //update direction of ball based on which side of the brick it hit
          //calculate the distance of the ball from each of 4 sides.
          //The smallest distance is the side the ball has it

          double leftSideDist = (MyBricks[i][0] - ballX).abs();
          double rightSideDist = (MyBricks[i][0] + brickWidth - ballX).abs();
          double topSideDist = (MyBricks[i][1] - ballY).abs();
          double bottomSideDist = (MyBricks[i][1] + brickHeight - ballY).abs();

          String min = findMin(
            leftSideDist,
            rightSideDist,
            topSideDist,
            bottomSideDist,
          );

          // Change direction based on side hit
          switch (min) {
            case 'left':
              ballXDirection = direction.LEFT;
              break;
            case 'right':
              ballXDirection = direction.RIGHT;
              break;
            case 'up':
              ballYDirection = direction.UP;
              break;
            case 'down':
              ballYDirection = direction.DOWN;
              break;
          }
        });
      }
    }
  }

  //returns the smallest side
  String findMin(double a, double b, double c, double d) {
    List<double> myList = [a, b, c, d];

    double currentMin = a;
    for (int i = 0; i < myList.length; i++) {
      if (myList[i] < currentMin) {
        currentMin = myList[i];
      }
    }

    if ((currentMin - a).abs() < 0.01) {
      return 'left';
    } else if ((currentMin - b).abs() < 0.01) {
      return 'right';
    } else if ((currentMin - c).abs() < 0.01) {
      return 'top';
    } else if ((currentMin - d).abs() < 0.01) {
      return 'bottom';
    }

    return '';
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
      generateRandomBricks(); // 💥
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
                //tap to play
                CoverScreen(
                  hasGameStarted: hasGameStarted,
                  isGameOver: isGameOver,
                ),

                //game over screen
                GameOverScreen(isGameOver: isGameOver, function: resetGame),

                //ball
                MyBall(ballX: ballX, ballY: ballY),

                //player
                MyPlayer(playerX: playerX, playerWidth: playerWidth),

                //bricks
                MyBrick(
                  brickX: MyBricks[0][0],
                  brickY: MyBricks[0][1],
                  brickBroken: MyBricks[0][2],
                  brickWidth: brickWidth,
                  brickHeight: brickHeight,
                ),
                MyBrick(
                  brickX: MyBricks[1][0],
                  brickY: MyBricks[1][1],
                  brickBroken: MyBricks[1][2],
                  brickWidth: brickWidth,
                  brickHeight: brickHeight,
                ),
                MyBrick(
                  brickX: MyBricks[2][0],
                  brickY: MyBricks[2][1],
                  brickBroken: MyBricks[2][2],
                  brickWidth: brickWidth,
                  brickHeight: brickHeight,
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
