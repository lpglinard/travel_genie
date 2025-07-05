import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryDay {
  ItineraryDay({
    required this.id,
    required this.dayNumber,
    this.notes,
  });

  final String id;
  final int dayNumber;
  final String? notes;

  factory ItineraryDay.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ItineraryDay(
      id: doc.id,
      dayNumber: data['dayNumber'] as int? ?? 0,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dayNumber': dayNumber,
      if (notes != null) 'notes': notes,
    };
  }

  ItineraryDay copyWith({
    String? id,
    int? dayNumber,
    String? notes,
  }) {
    return ItineraryDay(
      id: id ?? this.id,
      dayNumber: dayNumber ?? this.dayNumber,
      notes: notes ?? this.notes,
    );
  }
}