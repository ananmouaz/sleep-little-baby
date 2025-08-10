import 'package:flutter/material.dart';
import 'package:white_noise/constants/app_styles.dart';
import 'package:white_noise/constants/app_styles.dart';
import 'package:white_noise/constants/app_styles.dart';
import 'package:white_noise/constants/app_styles.dart';
import 'package:white_noise/constants/app_styles.dart';
import 'package:white_noise/constants/app_styles.dart';
import 'package:white_noise/constants/app_styles.dart';

class TimerSelector extends StatelessWidget {
  final int duration;
  final ValueChanged<int?> onChanged;

  const TimerSelector({super.key, required this.duration, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<int>(
        value: duration,
        isExpanded: true,
        underline: Container(),
        items: [
          DropdownMenuItem(child: Text("1 minutes 🌙", style: AppStyles.caption,), value: 1),
          DropdownMenuItem(child: Text("15 minutes 🌙", style: AppStyles.caption,), value: 15),
          DropdownMenuItem(child: Text("30 minutes 🌙", style: AppStyles.caption,), value: 30),
          DropdownMenuItem(child: Text("1 hour 🌙", style: AppStyles.caption,), value: 60),
          DropdownMenuItem(child: Text("2 hours 🌙", style: AppStyles.caption,), value: 120),
          DropdownMenuItem(child: Text("4 hours 🌙", style: AppStyles.caption,), value: 240),
          DropdownMenuItem(child: Text("8 hours 🌙", style: AppStyles.caption,), value: 480),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
