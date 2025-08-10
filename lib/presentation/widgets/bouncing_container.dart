import 'dart:math';

import 'package:flutter/material.dart';

class BouncingContainer extends StatelessWidget {
  final Widget child;
  const BouncingContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(seconds: 2),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, sin(value * 2 * 3.14159) * 10),
          child: child,
        );
      },
      child: child,
    );
  }
}
