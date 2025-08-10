import 'package:flutter/material.dart';

class OnboardingImage extends StatelessWidget {
  const OnboardingImage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Image.asset(
        'assets/images/paywall_image.jpg',
        height: 220,
        width: double.infinity, // Adjust as needed
        fit: BoxFit.cover, // Ensures the image fills the container
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 30); // Start from bottom-left
    path.quadraticBezierTo(
      size.width / 4, size.height, // Control point
      size.width / 2, size.height - 30, // End point
    );
    path.quadraticBezierTo(
      size.width * 3 / 4, size.height - 60, // Control point
      size.width, size.height - 30, // End point
    );
    path.lineTo(size.width, 0); // Top-right corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
