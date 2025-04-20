import 'package:flutter/material.dart';

class MyBrick extends StatelessWidget {
  final brickX;
  final brickY;
  final brickHeight;
  final brickWidth;
  final bool brickBroken;

  MyBrick({
    this.brickHeight,
    this.brickWidth,
    this.brickX,
    this.brickY,
    required this.brickBroken,
  });

  @override
  Widget build(BuildContext context) {
    return brickBroken
        ? Container()
        : Container(
          alignment: Alignment(
            (2 * brickX + brickWidth) / (2 - brickWidth),
            brickY,
          ),
          child: Image.asset(
            'assets/images/duck.png',
            height: MediaQuery.of(context).size.height * brickHeight,
            width: MediaQuery.of(context).size.width * brickWidth / 2,
            fit: BoxFit.contain,
          ),
        );
  }
}
