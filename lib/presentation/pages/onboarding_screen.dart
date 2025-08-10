import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_noise/presentation/pages/paywall_screen.dart';
import 'package:white_noise/presentation/pages/sound_grid_screen.dart';
import 'package:white_noise/presentation/widgets/animated_button.dart';
import '../../constants/app_styles.dart';
import '../widgets/onboarding_image.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background container with gradient
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[200]!, Colors.purple[100]!],
              ),
            ),
          ),
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                // Full-width image at the top
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: OnboardingImage(),
                ),
                // Content section with padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Main heading with enhanced styling
                      Text(
                        'Sleepy Time Sounds!',
                        style: AppStyles.h3,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      // Subheading with improved readability
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Join our magical journey to dreamland with soothing sounds! ✨',
                          style: AppStyles.title,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 12),
                      // Feature list with icons
                      ...buildFeatureList(),
                      // Extra padding at bottom to account for fixed button
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Fixed button at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.purple[100]!.withOpacity(0.5),
                    Colors.purple[100]!,
                  ],
                ),
              ),
              child: AnimatedButton(
                onPressed: () async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('hasCompletedOnboarding', true);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          PremiumPaywall(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation.drive(
                            CurveTween(curve: Curves.easeOut),
                          ),
                          child: child,
                        );
                      },
                      transitionDuration: Duration(milliseconds: 500),
                    ),
                  );
                },
                text: "Start Now 🚀",
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildFeatureList() {
    final features = [
      {'icon': Icons.nightlight_round, 'text': 'Peaceful bedtime sounds'},
      {'icon': Icons.auto_awesome, 'text': 'Magical Sleep Time'},
      {'icon': Icons.timer, 'text': 'Smart sleep timer'},
    ];

    return features.map((feature) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature['icon'] as IconData,
              color: Colors.indigo[800],
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
                feature['text'].toString(),
                style: AppStyles.caption
            ),
          ),
        ],
      ),
    )).toList();
  }
}