class TravelerProfile {
  const TravelerProfile({
    this.travelCompany = const [],
    this.budget,
    this.accommodationTypes = const [],
    this.interests = const [],
    this.gastronomicPreferences = const [],
    this.itineraryStyle,
    this.createdAt,
    this.updatedAt,
  });

  final List<TravelCompany> travelCompany;
  final TravelBudget? budget;
  final List<AccommodationType> accommodationTypes;
  final List<TravelInterest> interests;
  final List<GastronomicPreference> gastronomicPreferences;
  final ItineraryStyle? itineraryStyle;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TravelerProfile.fromJson(Map<String, dynamic> json) {
    return TravelerProfile(
      travelCompany:
          (json['travelCompany'] as List<dynamic>?)
              ?.map(
                (e) => TravelCompany.values.firstWhere(
                  (company) => company.name == e,
                  orElse: () => TravelCompany.solo,
                ),
              )
              .toList() ??
          [],
      budget: json['budget'] != null
          ? TravelBudget.values.firstWhere(
              (budget) => budget.name == json['budget'],
              orElse: () => TravelBudget.moderate,
            )
          : null,
      accommodationTypes:
          (json['accommodationTypes'] as List<dynamic>?)
              ?.map(
                (e) => AccommodationType.values.firstWhere(
                  (type) => type.name == e,
                  orElse: () => AccommodationType.comfortHotel,
                ),
              )
              .toList() ??
          [],
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map(
                (e) => TravelInterest.values.firstWhere(
                  (interest) => interest.name == e,
                  orElse: () => TravelInterest.culture,
                ),
              )
              .toList() ??
          [],
      gastronomicPreferences:
          (json['gastronomicPreferences'] as List<dynamic>?)
              ?.map(
                (e) => GastronomicPreference.values.firstWhere(
                  (pref) => pref.name == e,
                  orElse: () => GastronomicPreference.localFood,
                ),
              )
              .toList() ??
          [],
      itineraryStyle: json['itineraryStyle'] != null
          ? ItineraryStyle.values.firstWhere(
              (style) => style.name == json['itineraryStyle'],
              orElse: () => ItineraryStyle.detailed,
            )
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'travelCompany': travelCompany.map((e) => e.name).toList(),
      'budget': budget?.name,
      'accommodationTypes': accommodationTypes.map((e) => e.name).toList(),
      'interests': interests.map((e) => e.name).toList(),
      'gastronomicPreferences': gastronomicPreferences
          .map((e) => e.name)
          .toList(),
      'itineraryStyle': itineraryStyle?.name,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  TravelerProfile copyWith({
    List<TravelCompany>? travelCompany,
    TravelBudget? budget,
    List<AccommodationType>? accommodationTypes,
    List<TravelInterest>? interests,
    List<GastronomicPreference>? gastronomicPreferences,
    ItineraryStyle? itineraryStyle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TravelerProfile(
      travelCompany: travelCompany ?? this.travelCompany,
      budget: budget ?? this.budget,
      accommodationTypes: accommodationTypes ?? this.accommodationTypes,
      interests: interests ?? this.interests,
      gastronomicPreferences:
          gastronomicPreferences ?? this.gastronomicPreferences,
      itineraryStyle: itineraryStyle ?? this.itineraryStyle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isComplete {
    return travelCompany.isNotEmpty &&
        budget != null &&
        accommodationTypes.isNotEmpty &&
        interests.isNotEmpty &&
        gastronomicPreferences.isNotEmpty &&
        itineraryStyle != null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TravelerProfile &&
        _listEquals(other.travelCompany, travelCompany) &&
        other.budget == budget &&
        _listEquals(other.accommodationTypes, accommodationTypes) &&
        _listEquals(other.interests, interests) &&
        _listEquals(other.gastronomicPreferences, gastronomicPreferences) &&
        other.itineraryStyle == itineraryStyle &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(travelCompany),
      budget,
      Object.hashAll(accommodationTypes),
      Object.hashAll(interests),
      Object.hashAll(gastronomicPreferences),
      itineraryStyle,
      createdAt,
      updatedAt,
    );
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

enum TravelCompany { solo, couple, familyWithChildren, friendsGroup }

enum TravelBudget { economic, moderate, luxury }

enum AccommodationType { hostel, budgetHotel, comfortHotel, resort, apartment }

enum TravelInterest {
  culture,
  nature,
  nightlife,
  gastronomy,
  shopping,
  relaxation,
}

enum GastronomicPreference {
  localFood,
  gourmetRestaurants,
  dietaryRestrictions,
}

enum ItineraryStyle { detailed, spontaneous }
