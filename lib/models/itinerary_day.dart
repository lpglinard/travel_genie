import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_genie/models/place.dart';

class ItineraryDay {
  ItineraryDay({
    required this.date,
    required this.places,
  });

  final DateTime date;
  final List<Place> places;

  factory ItineraryDay.fromMap(Map<String, dynamic> map) {
    return ItineraryDay(
      date: (map['date'] as Timestamp).toDate(),
      places: (map['places'] as List<dynamic>)
          .map((e) => Place.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'places': places.map((e) => e.toMap()).toList(),
    };
  }
}