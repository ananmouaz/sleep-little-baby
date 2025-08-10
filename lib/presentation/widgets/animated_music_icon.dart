import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedMusicIcon extends StatelessWidget {
  bool isPlaying;

  AnimatedMusicIcon({super.key, this.isPlaying = false} );

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: isPlaying ? 1 : 0),
      duration: Duration(seconds: 2),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 1 + (isPlaying ? sin(value * 2 * 3.14159) * 0.1 : 0),
          child: Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.music_note,
              size: 80,
              color: Colors.purple,
            ),
          ),
        );
      },
    );
  }
}
