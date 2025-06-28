import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// Utility class for working with place types.
/// Provides mapping between place type identifiers and their human-readable names.
class PlaceType {
  /// List of all supported place types
  static const List<String> allTypes = [
    'accounting',
    'airport',
    'amusement_park',
    'aquarium',
    'art_gallery',
    'atm',
    'bakery',
    'bank',
    'bar',
    'beauty_salon',
    'bicycle_store',
    'book_store',
    'bowling_alley',
    'bus_station',
    'cafe',
    'campground',
    'car_dealer',
    'car_rental',
    'car_repair',
    'car_wash',
    'casino',
    'cemetery',
    'church',
    'city_hall',
    'clothing_store',
    'convenience_store',
    'courthouse',
    'dentist',
    'department_store',
    'doctor',
    'drugstore',
    'electrician',
    'electronics_store',
    'embassy',
    'fire_station',
    'florist',
    'funeral_home',
    'furniture_store',
    'gas_station',
    'gym',
    'hair_care',
    'hardware_store',
    'hindu_temple',
    'home_goods_store',
    'hospital',
    'insurance_agency',
    'jewelry_store',
    'laundry',
    'lawyer',
    'library',
    'light_rail_station',
    'liquor_store',
    'local_government_office',
    'locksmith',
    'lodging',
    'meal_delivery',
    'meal_takeaway',
    'mosque',
    'movie_rental',
    'movie_theater',
    'moving_company',
    'museum',
    'night_club',
    'painter',
    'park',
    'parking',
    'pet_store',
    'pharmacy',
    'physiotherapist',
    'plumber',
    'police',
    'post_office',
    'primary_school',
    'real_estate_agency',
    'restaurant',
    'roofing_contractor',
    'rv_park',
    'school',
    'secondary_school',
    'shoe_store',
    'shopping_mall',
    'spa',
    'stadium',
    'storage',
    'store',
    'subway_station',
    'supermarket',
    'synagogue',
    'taxi_stand',
    'tourist_attraction',
    'train_station',
    'transit_station',
    'travel_agency',
    'university',
    'veterinary_care',
    'zoo',
  ];

  /// Map of place type identifiers to their human-readable names (for backward compatibility)
  static Map<String, String> get typeToReadableName {
    // Generate the map dynamically from the list of types
    return Map.fromEntries(
      allTypes.map((type) => MapEntry(type, _capitalizeFirstLetter(type))),
    );
  }

  /// Returns the human-readable name for a given place type.
  /// This method is provided for backward compatibility with existing code.
  /// For new code, use the version that takes a BuildContext parameter to get localized names.
  static String getReadableName(String type) {
    return _capitalizeFirstLetter(type);
  }

  /// Returns the localized human-readable name for a given place type.
  /// Uses the app's internationalization system to get localized place type names.
  /// If no mapping is available, falls back to a capitalized version of the type.
  static String getLocalizedName(BuildContext context, String type) {
    // Get the AppLocalizations instance
    final appLocalizations = AppLocalizations.of(context);

    // Convert the type to the localization key format (e.g., 'restaurant' -> 'placeTypeRestaurant')
    final localizationKey = _typeToLocalizationKey(type);

    // Try to get the localized string using the localization key
    try {
      // Use a simple approach to access the localized string
      return _getLocalizedString(appLocalizations, localizationKey) ??
          // Fall back to a capitalized version of the type
          _capitalizeFirstLetter(type);
    } catch (e) {
      // If there's an error, fall back to a capitalized version of the type
      return _capitalizeFirstLetter(type);
    }
  }

  /// Converts a place type to its corresponding localization key.
  /// For example, 'restaurant' -> 'placeTypeRestaurant'
  static String _typeToLocalizationKey(String type) {
    if (type.isEmpty) return '';

    // Convert snake_case to camelCase
    final camelCase = type
        .split('_')
        .asMap()
        .entries
        .map((entry) {
          final word = entry.value;
          if (entry.key == 0) return word;
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join('');

    // Add the 'placeType' prefix
    return 'placeType${camelCase[0].toUpperCase()}${camelCase.substring(1)}';
  }

  /// Gets a localized string from the AppLocalizations instance using a key.
  /// Returns null if the key doesn't exist.
  static String? _getLocalizedString(
    AppLocalizations appLocalizations,
    String key,
  ) {
    // This is a simplified approach that handles the most common place types
    // without using a large switch statement
    switch (key) {
      case 'placeTypeRestaurant':
        return appLocalizations.placeTypeRestaurant;
      case 'placeTypeAirport':
        return appLocalizations.placeTypeAirport;
      case 'placeTypeAmusementPark':
        return appLocalizations.placeTypeAmusementPark;
      case 'placeTypeAquarium':
        return appLocalizations.placeTypeAquarium;
      case 'placeTypeArtGallery':
        return appLocalizations.placeTypeArtGallery;
      case 'placeTypeAtm':
        return appLocalizations.placeTypeAtm;
      case 'placeTypeBakery':
        return appLocalizations.placeTypeBakery;
      case 'placeTypeBank':
        return appLocalizations.placeTypeBank;
      case 'placeTypeBar':
        return appLocalizations.placeTypeBar;
      case 'placeTypeBeautySalon':
        return appLocalizations.placeTypeBeautySalon;
      case 'placeTypeBicycleStore':
        return appLocalizations.placeTypeBicycleStore;
      case 'placeTypeBookStore':
        return appLocalizations.placeTypeBookStore;
      case 'placeTypeBowlingAlley':
        return appLocalizations.placeTypeBowlingAlley;
      case 'placeTypeBusStation':
        return appLocalizations.placeTypeBusStation;
      case 'placeTypeCafe':
        return appLocalizations.placeTypeCafe;
      case 'placeTypeCampground':
        return appLocalizations.placeTypeCampground;
      case 'placeTypeCarDealer':
        return appLocalizations.placeTypeCarDealer;
      case 'placeTypeCarRental':
        return appLocalizations.placeTypeCarRental;
      case 'placeTypeCarRepair':
        return appLocalizations.placeTypeCarRepair;
      case 'placeTypeCarWash':
        return appLocalizations.placeTypeCarWash;
      case 'placeTypeCasino':
        return appLocalizations.placeTypeCasino;
      case 'placeTypeCemetery':
        return appLocalizations.placeTypeCemetery;
      case 'placeTypeChurch':
        return appLocalizations.placeTypeChurch;
      case 'placeTypeCityHall':
        return appLocalizations.placeTypeCityHall;
      case 'placeTypeClothingStore':
        return appLocalizations.placeTypeClothingStore;
      case 'placeTypeConvenienceStore':
        return appLocalizations.placeTypeConvenienceStore;
      case 'placeTypeCourthouse':
        return appLocalizations.placeTypeCourthouse;
      case 'placeTypeDentist':
        return appLocalizations.placeTypeDentist;
      case 'placeTypeDepartmentStore':
        return appLocalizations.placeTypeDepartmentStore;
      case 'placeTypeDoctor':
        return appLocalizations.placeTypeDoctor;
      case 'placeTypeDrugstore':
        return appLocalizations.placeTypeDrugstore;
      case 'placeTypeElectrician':
        return appLocalizations.placeTypeElectrician;
      case 'placeTypeElectronicsStore':
        return appLocalizations.placeTypeElectronicsStore;
      case 'placeTypeEmbassy':
        return appLocalizations.placeTypeEmbassy;
      case 'placeTypeFireStation':
        return appLocalizations.placeTypeFireStation;
      case 'placeTypeFlorist':
        return appLocalizations.placeTypeFlorist;
      case 'placeTypeFuneralHome':
        return appLocalizations.placeTypeFuneralHome;
      case 'placeTypeFurnitureStore':
        return appLocalizations.placeTypeFurnitureStore;
      case 'placeTypeGasStation':
        return appLocalizations.placeTypeGasStation;
      case 'placeTypeGym':
        return appLocalizations.placeTypeGym;
      case 'placeTypeHairCare':
        return appLocalizations.placeTypeHairCare;
      case 'placeTypeHardwareStore':
        return appLocalizations.placeTypeHardwareStore;
      case 'placeTypeHinduTemple':
        return appLocalizations.placeTypeHinduTemple;
      case 'placeTypeHomeGoodsStore':
        return appLocalizations.placeTypeHomeGoodsStore;
      case 'placeTypeHospital':
        return appLocalizations.placeTypeHospital;
      case 'placeTypeInsuranceAgency':
        return appLocalizations.placeTypeInsuranceAgency;
      case 'placeTypeJewelryStore':
        return appLocalizations.placeTypeJewelryStore;
      case 'placeTypeLaundry':
        return appLocalizations.placeTypeLaundry;
      case 'placeTypeLawyer':
        return appLocalizations.placeTypeLawyer;
      case 'placeTypeLibrary':
        return appLocalizations.placeTypeLibrary;
      case 'placeTypeLightRailStation':
        return appLocalizations.placeTypeLightRailStation;
      case 'placeTypeLiquorStore':
        return appLocalizations.placeTypeLiquorStore;
      case 'placeTypeLocalGovernmentOffice':
        return appLocalizations.placeTypeLocalGovernmentOffice;
      case 'placeTypeLocksmith':
        return appLocalizations.placeTypeLocksmith;
      case 'placeTypeLodging':
        return appLocalizations.placeTypeLodging;
      case 'placeTypeMealDelivery':
        return appLocalizations.placeTypeMealDelivery;
      case 'placeTypeMealTakeaway':
        return appLocalizations.placeTypeMealTakeaway;
      case 'placeTypeMosque':
        return appLocalizations.placeTypeMosque;
      case 'placeTypeMovieRental':
        return appLocalizations.placeTypeMovieRental;
      case 'placeTypeMovieTheater':
        return appLocalizations.placeTypeMovieTheater;
      case 'placeTypeMovingCompany':
        return appLocalizations.placeTypeMovingCompany;
      case 'placeTypeMuseum':
        return appLocalizations.placeTypeMuseum;
      case 'placeTypeNightClub':
        return appLocalizations.placeTypeNightClub;
      case 'placeTypePainter':
        return appLocalizations.placeTypePainter;
      case 'placeTypePark':
        return appLocalizations.placeTypePark;
      case 'placeTypeParking':
        return appLocalizations.placeTypeParking;
      case 'placeTypePetStore':
        return appLocalizations.placeTypePetStore;
      case 'placeTypePharmacy':
        return appLocalizations.placeTypePharmacy;
      case 'placeTypePhysiotherapist':
        return appLocalizations.placeTypePhysiotherapist;
      case 'placeTypePlumber':
        return appLocalizations.placeTypePlumber;
      case 'placeTypePolice':
        return appLocalizations.placeTypePolice;
      case 'placeTypePostOffice':
        return appLocalizations.placeTypePostOffice;
      case 'placeTypePrimarySchool':
        return appLocalizations.placeTypePrimarySchool;
      case 'placeTypeRealEstateAgency':
        return appLocalizations.placeTypeRealEstateAgency;
      case 'placeTypeAccounting':
        return appLocalizations.placeTypeAccounting;
      case 'placeTypeRoofingContractor':
        return appLocalizations.placeTypeRoofingContractor;
      case 'placeTypeRvPark':
        return appLocalizations.placeTypeRvPark;
      case 'placeTypeSchool':
        return appLocalizations.placeTypeSchool;
      case 'placeTypeSecondarySchool':
        return appLocalizations.placeTypeSecondarySchool;
      case 'placeTypeShoeStore':
        return appLocalizations.placeTypeShoeStore;
      case 'placeTypeShoppingMall':
        return appLocalizations.placeTypeShoppingMall;
      case 'placeTypeSpa':
        return appLocalizations.placeTypeSpa;
      case 'placeTypeStadium':
        return appLocalizations.placeTypeStadium;
      case 'placeTypeStorage':
        return appLocalizations.placeTypeStorage;
      case 'placeTypeStore':
        return appLocalizations.placeTypeStore;
      case 'placeTypeSubwayStation':
        return appLocalizations.placeTypeSubwayStation;
      case 'placeTypeSupermarket':
        return appLocalizations.placeTypeSupermarket;
      case 'placeTypeSynagogue':
        return appLocalizations.placeTypeSynagogue;
      case 'placeTypeTaxiStand':
        return appLocalizations.placeTypeTaxiStand;
      case 'placeTypeTouristAttraction':
        return appLocalizations.placeTypeTouristAttraction;
      case 'placeTypeTrainStation':
        return appLocalizations.placeTypeTrainStation;
      case 'placeTypeTransitStation':
        return appLocalizations.placeTypeTransitStation;
      case 'placeTypeTravelAgency':
        return appLocalizations.placeTypeTravelAgency;
      case 'placeTypeUniversity':
        return appLocalizations.placeTypeUniversity;
      case 'placeTypeVeterinaryCare':
        return appLocalizations.placeTypeVeterinaryCare;
      case 'placeTypeZoo':
        return appLocalizations.placeTypeZoo;
      default:
        return null;
    }
  }

  /// Capitalizes the first letter of a string and replaces underscores with spaces.
  static String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;

    // Replace underscores with spaces
    final withSpaces = text.replaceAll('_', ' ');

    // Capitalize first letter of each word
    return withSpaces
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}
