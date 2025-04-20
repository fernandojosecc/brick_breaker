import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoverScreen extends StatelessWidget {
  final bool hasGameStarted;
  final bool isGameOver;

  //font
  static var gameFont = GoogleFonts.pressStart2p(
    textStyle: TextStyle(
      color: Colors.blue[600],
      letterSpacing: 0,
      fontSize: 28,
    ),
  );

  const CoverScreen({
    Key? key,
    required this.hasGameStarted,
    required this.isGameOver,
  });

  @override
  Widget build(BuildContext context) {
    return hasGameStarted
        ? Container()
        : Stack(
          children: [
            Container(
              alignment: Alignment(0, -0.1),
              child: Text('DUCK BREAKER', style: gameFont),
            ),
            Container(
              alignment: Alignment(0, -0.5),
              child: Text(
                'tap to play',
                style: TextStyle(color: Colors.blueAccent[400]),
              ),
            ),
          ],
        );
  }
}
