import 'package:flutter/material.dart';

import '../../models/trip.dart';

/// Widget that displays the content of a placeholder image
class PlaceholderContent extends StatelessWidget {
  final Trip trip;
  final MaterialColor color;

  const PlaceholderContent({
    super.key,
    required this.trip,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.landscape, size: 50, color: color),
        const SizedBox(height: 8),
        Text(
          trip.title.isNotEmpty ? trip.title : 'Trip',
          style: TextStyle(color: color.shade800, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
