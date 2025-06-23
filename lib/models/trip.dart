import 'package:cloud_firestore/cloud_firestore.dart';
import 'itinerary_day.dart';
import 'place.dart';

class Trip {
  Trip({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.coverImageUrl,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.places = const [],
    this.participants = const [],
    this.itinerary = const [],
  });

  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String coverImageUrl;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final List<Place> places;
  final List<String> participants;
  final List<ItineraryDay> itinerary;

  factory Trip.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse participants if they exist
    List<String> participants = [];
    if (data['participants'] != null && data['participants'] is List) {
      participants = (data['participants'] as List).cast<String>();
    }
    final rawItinerary = data['itinerary'] as List<dynamic>? ?? [];
    final itinerary = rawItinerary
        .map((e) => ItineraryDay.fromMap(e as Map<String, dynamic>))
        .toList();

    return Trip(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      coverImageUrl: data['coverImageUrl'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isArchived: data['isArchived'] as bool? ?? false,
      places: const [], // Places are now stored in a sub-collection
      participants: participants,
      itinerary: itinerary,
    );
  }

  // Create a copy of this Trip with the given fields replaced
  Trip copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? coverImageUrl,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    List<Place>? places,
    List<String>? participants,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      places: places ?? this.places,
      participants: participants ?? this.participants,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'coverImageUrl': coverImageUrl,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isArchived': isArchived,
      'participants': participants,
      // Não incluir 'places' aqui, pois são salvos na subcoleção
    };
  }
}
