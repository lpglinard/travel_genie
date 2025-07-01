import 'package:cloud_firestore/cloud_firestore.dart';

import 'itinerary_day.dart';
import 'place.dart';

class Trip {
  const Trip({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.coverImageUrl,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.placeId,
    this.isArchived = false,
    this.isLoadingCoverImage = false,
    this.isLoadingDescription = false,
    this.participants = const [],
    this.places,
    this.itinerary,
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
  final String? placeId;
  final bool isArchived;
  final bool isLoadingCoverImage;
  final bool isLoadingDescription;
  final List<String> participants;

  /// Dados carregados separadamente das subcoleções:
  final List<Place>? places;
  final List<ItineraryDay>? itinerary;

  factory Trip.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

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
      placeId: data['placeId'] as String?,
      isArchived: data['isArchived'] as bool? ?? false,
      isLoadingCoverImage: data['isLoadingCoverImage'] as bool? ?? false,
      isLoadingDescription: data['isLoadingDescription'] as bool? ?? false,
      participants: (data['participants'] as List?)?.cast<String>() ?? const [],
      places: null,
      // serão carregados separadamente
      itinerary: null, // idem
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
      'placeId': placeId,
      'isArchived': isArchived,
      'isLoadingCoverImage': isLoadingCoverImage,
      'isLoadingDescription': isLoadingDescription,
      'participants': participants,
      // NÃO incluir `places` ou `itinerary` aqui!
    };
  }

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
    String? placeId,
    bool? isArchived,
    bool? isLoadingCoverImage,
    bool? isLoadingDescription,
    List<String>? participants,
    List<Place>? places,
    List<ItineraryDay>? itinerary,
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
      placeId: placeId ?? this.placeId,
      isArchived: isArchived ?? this.isArchived,
      isLoadingCoverImage: isLoadingCoverImage ?? this.isLoadingCoverImage,
      isLoadingDescription: isLoadingDescription ?? this.isLoadingDescription,
      participants: participants ?? this.participants,
      places: places ?? this.places,
      itinerary: itinerary ?? this.itinerary,
    );
  }
}
