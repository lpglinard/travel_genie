import 'package:cloud_firestore/cloud_firestore.dart';
import 'place.dart';

class ItineraryDay {
  ItineraryDay({
    required this.id,
    required this.date,
    required this.order,
    this.places = const [],
  });

  final String id;
  final DateTime date;
  final int order;
  final List<Place> places;

  factory ItineraryDay.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    return ItineraryDay(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      order: data['order'] as int? ?? 0,
      places: const [], // será carregado separadamente por stream
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'order': order,
    };
  }

  ItineraryDay copyWith({
    String? id,
    DateTime? date,
    int? order,
    List<Place>? places,
  }) {
    return ItineraryDay(
      id: id ?? this.id,
      date: date ?? this.date,
      order: order ?? this.order,
      places: places ?? this.places,
    );
  }
}