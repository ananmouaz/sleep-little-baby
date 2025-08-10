import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:white_noise/presentation/pages/onboarding_screen.dart';
import 'package:white_noise/presentation/pages/sound_grid_screen.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;


  runApp(WhiteNoiseApp(hasCompletedOnboarding: hasCompletedOnboarding,));
}

class WhiteNoiseApp extends StatefulWidget {
  final bool hasCompletedOnboarding;

  const WhiteNoiseApp({super.key, required this.hasCompletedOnboarding});

  @override
  State<WhiteNoiseApp> createState() => _WhiteNoiseAppState();
}

class _WhiteNoiseAppState extends State<WhiteNoiseApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'White Noise for Kids',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: widget.hasCompletedOnboarding ? SoundGridScreen() : OnboardingScreen(),
    );
  }
}

