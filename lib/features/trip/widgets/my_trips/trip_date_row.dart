import 'package:flutter/material.dart';

/// Widget that displays the trip dates
class TripDateRow extends StatelessWidget {
  final String startDate;
  final String endDate;

  const TripDateRow({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 16),
        const SizedBox(width: 8),
        Text('$startDate - $endDate'),
      ],
    );
  }
}
