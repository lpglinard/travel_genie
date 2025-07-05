# Travel Genie Development Guidelines

## Build/Configuration Instructions


### Initial Setup
1. **Install Dependencies**
   ```bash
   flutter pub get
   ```
2. **Firebase Configuration**
    - Firebase is used for authentication, Firestore, analytics, performance monitoring, and crashlytics.
    - The configuration is set in `lib/firebase_options.dart`.
    - Ensure you have access to the correct Firebase project for development.
3. **Localization**
    - Supports English and Portuguese.
    - Localization files are in `lib/l10n/`.
    - After any localization change, generate files:
   ```bash
   flutter gen-l10n
   ```
4. **Custom Fonts**
    - Nunito font family with multiple weights is used.
    - Font files are in the `fonts/` directory.

### Build Commands
- **Development:** `flutter run`
- **Release (Android):** `flutter build apk --release`
- **Release (iOS):** `flutter build ios --release`
- **Web:** `flutter build web`

**Note:** Use `flutter run` for development. Use `flutter test` for testing (see Testing Guidelines).

## Testing Guidelines

### Test Configuration
- Uses `flutter_test` for unit tests and `integration_test` for integration tests.
- `network_image_mock` is available for mocking network images.
- SharedPreferences mocking is set up for local storage testing.

### Running Tests
- **All tests:** `flutter test`
- **Specific file:** `flutter test test/filename_test.dart`
- **Integration tests:** `flutter test integration_test/`

### Writing New Tests
1. Place test files in `test/` with the `_test.dart` suffix.
2. Use this structure for service tests:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_genie/services/your_service.dart';

void main() {
  group('YourService', () {
    late YourService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      service = YourService(prefs);
    });

    test('should perform expected behavior', () async {
      // Test implementation
    });
  });
}
```

### Example
See `test/preferences_service_test.dart` for:
- Service testing with mocks
- Async operation testing
- State verification
- Setup/teardown patterns

## Code Architecture

### Project Structure
The project follows a feature-based architecture with strict adherence to the "one widget/model per file" rule:
```
lib/
├── app.dart                 # Main app configuration
├── main.dart                # Entry point
├── router.dart              # App routing
├── core/                    # Shared functionality
│   ├── config/              # Config settings
│   ├── extensions/          # Dart extensions
│   ├── models/              # Shared data models
│   ├── pages/               # Core UI screens
│   ├── services/            # Core services
│   ├── theme/               # Theming
│   ├── utils/               # Utility functions
│   └── widgets/             # Shared UI components
├── features/                # Feature-specific code
│   ├── authentication/      # Authentication
│   ├── challenge/           # Challenges/badges
│   │   ├── models/          # Challenge-specific models
│   │   ├── providers/       # Challenge state management
│   │   └── services/        # Challenge business logic
│   ├── place/               # Places/locations
│   ├── search/              # Search
│   ├── social/              # Social features
│   ├── trip/                # Trip management
│   └── user/                # User management
│       ├── models/          # User data models (one per file)
│       │   ├── traveler_profile.dart
│       │   ├── traveler_profile_enums.dart  # Export file
│       │   ├── travel_company.dart
│       │   ├── travel_budget.dart
│       │   ├── accommodation_type.dart
│       │   ├── travel_interest.dart
│       │   ├── gastronomic_preference.dart
│       │   └── itinerary_style.dart
│       ├── pages/           # User-related pages
│       ├── providers/       # User state management
│       ├── services/        # User business logic
│       └── widgets/         # User-specific widgets
│           └── profile/     # Profile-related widgets (one per file)
│               ├── introduction_card.dart
│               ├── section_card.dart
│               ├── travel_company_section.dart
│               ├── budget_section.dart
│               ├── accommodation_section.dart
│               ├── interests_section.dart
│               ├── gastronomic_section.dart
│               ├── itinerary_style_section.dart
│               └── action_buttons.dart
└── l10n/                    # Localization files
```

### Abstract vs Implementation Separation

To keep code clean and testable, **do not declare abstract classes and their implementations in the same Dart file**.

**Recommended Example:**
```
lib/
└── services/
    ├── trip_repository.dart            # Abstract class TripRepository
    ├── firestore_trip_repository.dart  # Concrete implementation
```

**trip_repository.dart**
```dart
abstract class TripRepository {
  Future<String> createTrip(Trip trip);
  Future<Trip?> getTripById(String tripId);
  Stream<Trip?> streamTripById(String tripId);
}
```

**firestore_trip_repository.dart**
```dart
class FirestoreTripRepository implements TripRepository {
  final FirebaseFirestore _firestore;

  FirestoreTripRepository(this._firestore);

  @override
  Future<String> createTrip(Trip trip) async {
    final ref = await _firestore.collection('trips').add(trip.toFirestore());
    return ref.id;
  }

  @override
  Future<Trip?> getTripById(String tripId) async {
    final doc = await _firestore.collection('trips').doc(tripId).get();
    return doc.exists ? Trip.fromFirestore(doc) : null;
  }

  @override
  Stream<Trip?> streamTripById(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .snapshots()
        .map((doc) => doc.exists ? Trip.fromFirestore(doc) : null);
  }
}
```
This separation improves maintainability, readability, and testability.

## Coding Standards

### SOLID Principles (MANDATORY)

**All code must follow SOLID principles.**

#### S - Single Responsibility Principle (SRP)
- Each class should have only one reason to change and one responsibility.
- **Good Example:**
  ```dart
  class UserAuthenticationService {
    Future<User?> signIn(String email, String password) { /* ... */ }
    Future<void> signOut() { /* ... */ }
  }
  class UserProfileService {
    Future<UserProfile> getProfile(String userId) { /* ... */ }
    Future<void> updateProfile(UserProfile profile) { /* ... */ }
  }
  ```
- **Bad Example:**
  ```dart
  class UserService {
    Future<User?> signIn(String email, String password) { /* ... */ }
    Future<UserProfile> getProfile(String userId) { /* ... */ }
    Future<void> sendNotification(String message) { /* ... */ }
  }
  ```

#### O - Open/Closed Principle (OCP)
- Classes should be open for extension, closed for modification.
- Use abstract classes/interfaces and composition.
- **Example:**
  ```dart
  abstract class PaymentProcessor {
    Future<PaymentResult> processPayment(double amount);
  }
  class CreditCardProcessor extends PaymentProcessor {
    @override
    Future<PaymentResult> processPayment(double amount) { /* ... */ }
  }
  class PayPalProcessor extends PaymentProcessor {
    @override
    Future<PaymentResult> processPayment(double amount) { /* ... */ }
  }
  ```

#### L - Liskov Substitution Principle (LSP)
- Subclasses must be substitutable for their base classes.
- **Example:**
  ```dart
  abstract class DataRepository {
    Future<List<T>> getAll<T>();
    Future<T?> getById<T>(String id);
  }
  class FirestoreRepository extends DataRepository {
    @override
    Future<List<T>> getAll<T>() { /* ... */ }
    @override
    Future<T?> getById<T>(String id) { /* ... */ }
  }
  ```

#### I - Interface Segregation Principle (ISP)
- Prefer small, focused interfaces over large, general ones.
- **Example:**
  ```dart
  abstract class Readable {
    Future<String> read();
  }
  abstract class Writable {
    Future<void> write(String data);
  }
  abstract class Cacheable {
    Future<void> cache(String key, dynamic data);
  }
  class FileReader implements Readable {
    @override
    Future<String> read() { /* ... */ }
  }
  class CachedFileManager implements Readable, Writable, Cacheable {
    // Implements all interfaces
  }
  ```

#### D - Dependency Inversion Principle (DIP)
- High-level modules should depend on abstractions, not concrete implementations.
- Use dependency injection and providers.
- **Good Example:**
  ```dart
  abstract class DatabaseService {
    Future<Map<String, dynamic>?> getData(String id);
  }
  class UserService {
    UserService(this._database);
    final DatabaseService _database;
    Future<User?> getUser(String id) async {
      final data = await _database.getData(id);
      return data != null ? User.fromJson(data) : null;
    }
  }
  ```
- **Bad Example:**
  ```dart
  class UserService {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    Future<User?> getUser(String id) async {
      // Tightly coupled to Firestore
    }
  }
  ```

**Enforcement:**
- All code must be reviewed for SOLID compliance before merging.
- Refactor code violating SOLID when touched.
- All architecture decisions must consider SOLID.
- SOLID-compliant code is easier to test.

### Services
- Use dependency injection via constructors.
- Provide clear APIs with synchronous getters and async state changes.
- Handle errors with null checks.
- **Example:**
```dart
class PreferencesService {
  PreferencesService(this._prefs);
  final SharedPreferences _prefs;
  Locale? get locale {
    final code = _prefs.getString('locale');
    return code != null ? Locale(code) : null;
  }
  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove('locale');
    } else {
      await _prefs.setString('locale', locale.languageCode);
    }
  }
}
```

### Data Models
- Use immutable classes with `final` fields.
- Implement robust JSON serialization/deserialization.
- Handle null safety and use factory constructors for parsing.
- **Example:**
```dart
class Place {
  const Place({
    required this.placeId,
    required this.displayName,
    this.optionalField,
    PlaceCategory? category,
  }) : category = category ?? PlaceCategories.determineCategoryFromTypes(types);

  final String placeId;
  final String displayName;
  final PlaceCategory? optionalField;
  final PlaceCategory category;

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeId: (json['placeId'] ?? json['id'] ?? json['place_id']) as String? ?? '',
      // ... handle all fields with null safety
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      // ... include all fields
    };
  }
}
```

### Widgets
- **Avoid** private builder methods (e.g., `_buildDraggablePlace`).
- **Prefer** reusable widget classes.
- Only use builder methods for trivial UI elements.

**Discouraged:**
```dart
Widget _buildDraggablePlace(BuildContext context, Place place) {
  return LongPressDraggable<DraggedPlaceData>(
    data: DraggedPlaceData(place: place, fromDayId: null),
    feedback: _buildDragFeedback(context, place),
    child: _buildPlaceChip(context, place),
  );
}
```

**Recommended:**
```dart
class DraggablePlace extends StatelessWidget {
  const DraggablePlace({
    super.key,
    required this.place,
    this.fromDayId,
  });
  final Place place;
  final String? fromDayId;
  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<DraggedPlaceData>(
      data: DraggedPlaceData(place: place, fromDayId: fromDayId),
      feedback: DragFeedback(place: place),
      child: PlaceChip(place: place),
    );
  }
}
```
**Benefits:** Reusability, testability, clearer widget tree, and better performance.

## Internationalization

### Rules for String Usage
- **MANDATORY:** All user-facing text in widgets must use internationalization.
- **NO hardcoded/fixed text** in any widget.
- Support for English (`en`) and Portuguese (`pt`).
- Locale detection falls back to English.
- Use `flutter gen-l10n` after localization changes.
- Localization files are in `lib/l10n/`.
- Always use `AppLocalizations.of(context)` (or equivalent) for all user-visible strings.

### Required Patterns
```dart
Text(AppLocalizations.of(context)!.welcomeMessage),
ElevatedButton(
  onPressed: () {},
  child: Text(AppLocalizations.of(context)!.searchPlaces),
),
TextField(
  decoration: InputDecoration(
    hintText: AppLocalizations.of(context)!.enterDestination,
  ),
),
```

### Prohibited Patterns
```dart
// DO NOT do this:
Text('Welcome to Travel Genie'),
ElevatedButton(
  onPressed: () {},
  child: Text('Search Places'),
),
TextField(
  decoration: InputDecoration(
    hintText: 'Enter destination',
  ),
),
```

**Exception:** Fixed strings are allowed in debug-only functions or for non-user-facing configuration.

## Import Guidelines

- Use `package:` imports for all files outside the current directory:
  ```dart
  import 'package:travel_genie/features/trip/models/trip.dart';
  import 'package:travel_genie/features/user/providers/user_providers.dart';
  ```
- Use relative imports **only** for files in the same directory:
  ```dart
  import 'trip_cover_image.dart';
  ```
- **Do not use** `../../../` for imports. This is fragile and reduces clarity.

## Best Practices

### Error Handling
- Use try-catch for async operations, especially with Firebase.
- Provide meaningful error messages and fallback behavior.

### Performance Tips
- Use `cached_network_image` for images.
- Dispose widgets and resources properly.
- Prefer `const` constructors where possible.

### Security Notes
- Firebase security rules are configured in `firestore.rules`.
- Sensitive config is handled via Firebase.
- User authentication is managed via Firebase Auth.

### Debugging
- Firebase Crashlytics is set up for error tracking.
- Use the `logging` package for logging.
- Test thoroughly on both iOS and Android before deployment.
