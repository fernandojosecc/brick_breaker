import 'package:flutter/material.dart';

class MyPlayer extends StatelessWidget {
  final double playerX; //range: -1 to 1
  final double playerWidth; //out of 2

  const MyPlayer({required this.playerX, required this.playerWidth});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final playerRealWidth = screenWidth * playerWidth / 2;
    final leftPosition =
        (screenWidth / 2) + (playerX * screenWidth / 2) - (playerRealWidth / 2);

    return Positioned(
      bottom: 40,
      left: leftPosition,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: playerRealWidth,
          height: 10,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}
