import 'package:flutter/material.dart';

class FancySlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const FancySlider({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.9),
      ),
      child: Slider(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.purple,
        inactiveColor: Colors.purple.withOpacity(0.2),
      ),
    );
  }
}
