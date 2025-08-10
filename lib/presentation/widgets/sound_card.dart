import 'package:flutter/material.dart';
import 'package:white_noise/constants/app_styles.dart';

import '../pages/sound_player_screen.dart';

class SoundCard extends StatelessWidget {
  final String name; final
  String emoji;
  final String audioFile;

  const SoundCard({super.key,  required this.name, required this.emoji, required this.audioFile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                SoundPlayerScreen(
                  sound: name,
                  audioFile: audioFile, // Pass the audio file path
                ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: 40),
            ),
            SizedBox(height: 10),
            Text(
              name,
              textAlign: TextAlign.center,
              style: AppStyles.title
            ),
          ],
        ),
      ),
    );
  }
}
