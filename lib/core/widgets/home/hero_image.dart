import 'package:flutter/material.dart';

class HeroImage extends StatelessWidget {
  const HeroImage({super.key, required this.imagePath, this.borderRadius = 12});

  final String imagePath;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(imagePath, fit: BoxFit.cover),
    );
  }
}
