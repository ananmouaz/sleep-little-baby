import 'package:flutter/material.dart';

class AppStyles {
  static TextStyle h2 = TextStyle(
    fontSize: 32,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
    color: Colors.indigo[900],
    shadows: [
      Shadow(
        offset: Offset(2.0, 2.0),
        blurRadius: 3.0,
        color: Colors.white.withOpacity(0.5),
      ),
    ],
  );

  static TextStyle h3 = TextStyle(
    fontSize: 22,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
    color: Colors.indigo[900],
  );

  static TextStyle h4 = TextStyle(
    fontSize: 18,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
    color: Colors.indigo[900],
  );

  static TextStyle title = TextStyle(
    fontSize: 18,
    fontFamily: 'Poppins',
    color: Colors.indigo[900],
  );

  static TextStyle caption = TextStyle(
    fontSize: 16,
    fontFamily: 'Poppins',
    color: Colors.indigo[900],
  );
}