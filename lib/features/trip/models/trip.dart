import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:travel_genie/core/models/location.dart';
import 'package:travel_genie/features/place/models/place.dart';
import 'package:travel_genie/features/trip/models/itinerary_day.dart';

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
    this.destinationAddress,
    this.location,
    this.locationGeopoint,
    this.isArchived = false,
    this.isLoadingCoverImage = false,
    this.isLoadingDescription = false,
    this.isLoadingItinerary = false,
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
  final String? destinationAddress;
  final Location? location;
  final GeoPoint? locationGeopoint;
  final bool isArchived;
  final bool isLoadingCoverImage;
  final bool isLoadingDescription;
  final bool isLoadingItinerary;
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
      destinationAddress: data['destinationAddress'] as String?,
      location: data['location'] != null 
          ? Location.fromJson(data['location'] as Map<String, dynamic>)
          : null,
      locationGeopoint: data['location_geopoint'] as GeoPoint?,
      isArchived: data['isArchived'] as bool? ?? false,
      isLoadingCoverImage: data['isLoadingCoverImage'] as bool? ?? false,
      isLoadingDescription: data['isLoadingDescription'] as bool? ?? false,
      isLoadingItinerary: data['isLoadingItinerary'] as bool? ?? false,
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
      'destinationAddress': destinationAddress,
      'location': location?.toMap(),
      'location_geopoint': locationGeopoint,
      'isArchived': isArchived,
      'isLoadingCoverImage': isLoadingCoverImage,
      'isLoadingDescription': isLoadingDescription,
      'isLoadingItinerary': isLoadingItinerary,
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
    String? destinationAddress,
    Location? location,
    GeoPoint? locationGeopoint,
    bool? isArchived,
    bool? isLoadingCoverImage,
    bool? isLoadingDescription,
    bool? isLoadingItinerary,
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
      destinationAddress: destinationAddress ?? this.destinationAddress,
      location: location ?? this.location,
      locationGeopoint: locationGeopoint ?? this.locationGeopoint,
      isArchived: isArchived ?? this.isArchived,
      isLoadingCoverImage: isLoadingCoverImage ?? this.isLoadingCoverImage,
      isLoadingDescription: isLoadingDescription ?? this.isLoadingDescription,
      isLoadingItinerary: isLoadingItinerary ?? this.isLoadingItinerary,
      participants: participants ?? this.participants,
      places: places ?? this.places,
      itinerary: itinerary ?? this.itinerary,
    );
  }
}
