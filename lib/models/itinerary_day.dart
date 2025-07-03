import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryDay {
  ItineraryDay({
    required this.id,
    required this.dayNumber,
  });

  final String id;
  final int dayNumber;

  factory ItineraryDay.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ItineraryDay(
      id: doc.id,
      dayNumber: data['dayNumber'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dayNumber': dayNumber,
    };
  }

  ItineraryDay copyWith({
    String? id,
    int? dayNumber,
  }) {
    return ItineraryDay(
      id: id ?? this.id,
      dayNumber: dayNumber ?? this.dayNumber,
    );
  }
}
