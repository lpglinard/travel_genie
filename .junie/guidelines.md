# Travel Genie Development Guidelines

## Build/Configuration Instructions

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Firebase CLI (for Firebase integration)
- Android Studio/Xcode for platform-specific builds

### Initial Setup
1. **Dependencies Installation**:
   ```bash
   flutter pub get
   ```

2. **Firebase Configuration**:
   - The project uses Firebase for authentication, Firestore, analytics, performance monitoring, and crashlytics
   - Firebase configuration is already set up in `lib/firebase_options.dart`
   - Ensure you have proper Firebase project access for development

3. **Localization Setup**:
   - The project supports English and Portuguese localization
   - Localization files are in `lib/l10n/`
   - Generate localization files after changes:
   ```bash
   flutter gen-l10n
   ```

4. **Custom Fonts**:
   - The project uses Nunito font family with multiple weights
   - Font files are located in the `fonts/` directory

### Build Commands
- **Development build**: `flutter run` (for running/launching the app)
- **Release build**: `flutter build apk --release` (Android) or `flutter build ios --release` (iOS)
- **Web build**: `flutter build web`

**Important**: Use `flutter run` to launch and run the app for development. To test implementations, use `flutter test` instead (see Testing Information section below).

## Testing Information

### Test Configuration
- The project uses `flutter_test` for unit testing and `integration_test` for integration testing
- Mock support is available via `network_image_mock` for network image testing
- SharedPreferences mocking is built-in for testing services that use local storage

### Running Tests
- **All tests**: `flutter test`
- **Specific test file**: `flutter test test/filename_test.dart`
- **Integration tests**: `flutter test integration_test/`

### Adding New Tests
1. Create test files in the `test/` directory with `_test.dart` suffix
2. Use the following structure for service tests:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_genie/services/your_service.dart';

void main() {
  group('YourService', () {
    late YourService service;

    setUp(() async {
      // Setup mock dependencies
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

### Test Example
A working test example is available in `test/preferences_service_test.dart` demonstrating:
- Service testing with mocked dependencies
- Async operation testing
- State verification
- Setup and teardown patterns

## Code Style and Architecture Guidelines


### Project Structure
The project follows a feature-based architecture:
```
lib/
├── app.dart                 # Main app configuration
├── main.dart               # Entry point
├── router.dart             # App routing configuration
├── core/                   # Core functionality and shared components
│   ├── config/             # Configuration settings
│   ├── extensions/         # Dart extensions
│   ├── models/             # Shared data models (Location, Photo, etc.)
│   ├── pages/              # Core UI screens (home page, etc.)
│   ├── services/           # Core business logic services
│   ├── theme/              # App theming
│   ├── utils/              # Utility functions
│   └── widgets/            # Shared reusable UI components
├── features/               # Feature-specific code organized by domain
│   ├── authentication/     # Authentication feature
│   │   ├── models/         # Authentication-specific models
│   │   ├── pages/          # Authentication UI screens
│   │   └── widgets/        # Authentication-specific widgets
│   ├── challenge/          # Challenges and badges feature
│   │   ├── models/         # Challenge and badge models
│   │   ├── providers/      # Challenge state management
│   │   └── services/       # Challenge business logic
│   ├── place/              # Places and location feature
│   │   ├── models/         # Place-related models
│   │   ├── pages/          # Place detail pages
│   │   ├── services/       # Place services (search, recommendations)
│   │   └── widgets/        # Place-specific widgets
│   ├── search/             # Search functionality
│   │   ├── models/         # Search-related models
│   │   ├── pages/          # Search results pages
│   │   ├── providers/      # Search state management
│   │   ├── services/       # Search business logic
│   │   └── widgets/        # Search-specific widgets
│   ├── social/             # Social features
│   │   ├── models/         # Social-related models
│   │   ├── pages/          # Social pages (groups, etc.)
│   │   ├── services/       # Social business logic
│   │   └── widgets/        # Social-specific widgets
│   ├── trip/               # Trip planning and management
│   │   ├── models/         # Trip, itinerary, and related models
│   │   ├── pages/          # Trip management pages
│   │   ├── providers/      # Trip state management
│   │   ├── services/       # Trip business logic
│   │   └── widgets/        # Trip-specific widgets
│   └── user/               # User management
│       ├── models/         # User data and profile models
│       ├── pages/          # User profile pages
│       ├── providers/      # User state management
│       ├── services/       # User business logic
│       └── widgets/        # User-specific widgets
└── l10n/                   # Localization files
```

### Abstract and Implementation Separation

Para manter o código limpo, testável e alinhado aos princípios SOLID (especialmente SRP e DIP), **não se deve declarar classes abstratas no mesmo arquivo Dart de suas implementações**.

#### Exemplo recomendado:

```
lib/
└── services/
    ├── trip_repository.dart            # classe abstrata TripRepository
    ├── firestore_trip_repository.dart  # implementação concreta
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

Essa separação favorece manutenibilidade, legibilidade e facilita a criação de testes unitários com mocks.

### SOLID Principles (MANDATORY)

**CRITICAL REQUIREMENT**: All source code in this project MUST adhere to SOLID principles as a fundamental standard. These principles are not optional and must be followed in every class, service, and component.

#### S - Single Responsibility Principle (SRP)
- **Rule**: Each class should have only one reason to change and should be responsible for only one part of the functionality
- **Implementation**: 
  - Services should handle only one specific domain (e.g., `ChallengeProgressService` only handles challenge progress, not user authentication)
  - Models should only represent data structure, not business logic
  - Widgets should focus on a single UI concern
- **Example**: 
  ```dart
  // GOOD - Single responsibility
  class UserAuthenticationService {
    Future<User?> signIn(String email, String password) { /* ... */ }
    Future<void> signOut() { /* ... */ }
  }

  class UserProfileService {
    Future<UserProfile> getProfile(String userId) { /* ... */ }
    Future<void> updateProfile(UserProfile profile) { /* ... */ }
  }

  // BAD - Multiple responsibilities
  class UserService {
    Future<User?> signIn(String email, String password) { /* ... */ }
    Future<UserProfile> getProfile(String userId) { /* ... */ }
    Future<void> sendNotification(String message) { /* ... */ }
  }
  ```

#### O - Open/Closed Principle (OCP)
- **Rule**: Classes should be open for extension but closed for modification
- **Implementation**:
  - Use abstract classes and interfaces for extensibility
  - Prefer composition over inheritance
  - Use strategy pattern for varying behaviors
- **Example**:
  ```dart
  // GOOD - Open for extension, closed for modification
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
- **Rule**: Objects of a superclass should be replaceable with objects of a subclass without breaking the application
- **Implementation**:
  - Subclasses must honor the contract of their parent class
  - Don't strengthen preconditions or weaken postconditions
  - Ensure behavioral compatibility
- **Example**:
  ```dart
  // GOOD - Proper substitution
  abstract class DataRepository {
    Future<List<T>> getAll<T>();
    Future<T?> getById<T>(String id);
  }

  class FirestoreRepository extends DataRepository {
    @override
    Future<List<T>> getAll<T>() {
      // Implementation that maintains the contract
    }

    @override
    Future<T?> getById<T>(String id) {
      // Implementation that maintains the contract
    }
  }
  ```

#### I - Interface Segregation Principle (ISP)
- **Rule**: Clients should not be forced to depend on interfaces they don't use
- **Implementation**:
  - Create specific, focused interfaces rather than large, general-purpose ones
  - Split large interfaces into smaller, more specific ones
  - Use mixins for optional functionality
- **Example**:
  ```dart
  // GOOD - Segregated interfaces
  abstract class Readable {
    Future<String> read();
  }

  abstract class Writable {
    Future<void> write(String data);
  }

  abstract class Cacheable {
    Future<void> cache(String key, dynamic data);
  }

  // Classes implement only what they need
  class FileReader implements Readable {
    @override
    Future<String> read() { /* ... */ }
  }

  class CachedFileManager implements Readable, Writable, Cacheable {
    // Implements all interfaces because it needs all functionality
  }

  // BAD - Fat interface
  abstract class FileManager {
    Future<String> read();
    Future<void> write(String data);
    Future<void> cache(String key, dynamic data);
    Future<void> compress(); // Not all implementations need this
  }
  ```

#### D - Dependency Inversion Principle (DIP)
- **Rule**: High-level modules should not depend on low-level modules. Both should depend on abstractions
- **Implementation**:
  - Use dependency injection through constructors
  - Depend on abstractions (interfaces/abstract classes), not concrete implementations
  - Use providers for dependency management (Riverpod in this project)
- **Example**:
  ```dart
  // GOOD - Depends on abstraction
  abstract class DatabaseService {
    Future<Map<String, dynamic>?> getData(String id);
  }

  class UserService {
    UserService(this._database); // Dependency injection

    final DatabaseService _database; // Depends on abstraction

    Future<User?> getUser(String id) async {
      final data = await _database.getData(id);
      return data != null ? User.fromJson(data) : null;
    }
  }

  // BAD - Depends on concrete implementation
  class UserService {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Direct dependency

    Future<User?> getUser(String id) async {
      // Tightly coupled to Firestore
    }
  }
  ```

### SOLID Principles Enforcement
- **Code Reviews**: All code must be reviewed for SOLID compliance before merging
- **Refactoring**: Existing code that violates SOLID principles should be refactored when touched
- **Architecture Decisions**: All architectural decisions must consider SOLID principles
- **Testing**: SOLID-compliant code is easier to test - use this as a quality indicator

### Code Conventions

#### Data Models
- Use immutable classes with `final` fields
- Implement comprehensive JSON serialization with fallback field names
- Handle null safety with proper defaults
- Use factory constructors for JSON parsing
- Example pattern from `Place` model:
```dart
class Place {
  const Place({
    required this.placeId,
    required this.displayName,
    // ... other required fields
    this.optionalField,
    PlaceCategory? category,
  }) : category = category ?? PlaceCategories.determineCategoryFromTypes(types);

  final String placeId;
  final String displayName;
  final PlaceCategory? optionalField;
  final PlaceCategory category;

  factory Place.fromJson(Map<String, dynamic> json) {
    // Robust JSON parsing with fallbacks
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

#### Services
- Use dependency injection through constructors
- Implement clean APIs with getters for synchronous operations and async methods for state changes
- Handle errors gracefully with proper null checks
- Example pattern from `PreferencesService`:
```dart
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  // Synchronous getters for cached values
  Locale? get locale {
    final code = _prefs.getString('locale');
    return code != null ? Locale(code) : null;
  }

  // Async methods for state changes
  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove('locale');
    } else {
      await _prefs.setString('locale', locale.languageCode);
    }
  }
}
```

#### Widget Builder Methods
- **Important**: Builder methods like `_buildDraggablePlace` should be **mostly avoided**
- Instead of creating private builder methods that return Widgets, create proper Flutter widgets when recommended and possible
- This improves code reusability, testability, and follows Flutter best practices
- Only use builder methods for very simple, one-off UI components that don't warrant their own widget class

**Discouraged Pattern** (avoid this):
```dart
/// Builds a single draggable place item - AVOID THIS PATTERN
Widget _buildDraggablePlace(BuildContext context, Place place) {
  return LongPressDraggable<DraggedPlaceData>(
    data: DraggedPlaceData(place: place, fromDayId: null),
    feedback: _buildDragFeedback(context, place),
    child: _buildPlaceChip(context, place),
  );
}
```

**Recommended Pattern** (use this instead):
```dart
/// A draggable place widget that can be reused across the app
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

**Benefits of proper Flutter widgets:**
- Better code organization and reusability
- Easier to test in isolation
- Clearer widget tree structure
- Better performance through widget caching
- Follows Flutter framework conventions

#### Widget Text and Internationalization
- **CRITICAL REQUIREMENT**: No widget should EVER display fixed/hardcoded text strings
- **ALL text displayed in widgets MUST use the project's internationalization strategy**
- Always use `AppLocalizations.of(context)` or equivalent localization methods for any user-facing text
- This applies to ALL text including: labels, buttons, error messages, placeholders, tooltips, and any other user-visible strings
- Even temporary or debug text should use localization keys to maintain consistency

**Prohibited Pattern** (NEVER do this):
```dart
// WRONG - Fixed text strings are FORBIDDEN
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

**Required Pattern** (ALWAYS do this):
```dart
// CORRECT - Always use localization
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

**Exception Handling:**
- If `AppLocalizations.of(context)` might be null, use null-aware operators or provide fallbacks
- For debugging purposes, you may use fixed strings in `debugPrint()` or similar debug-only functions
- API keys, URLs, and other non-user-facing configuration strings are exempt from this rule

#### State Management
- The project uses Riverpod for state management
- Providers are organized in the `providers/` directory
- Follow Riverpod best practices for provider composition and dependency injection

#### Firebase Integration
- Firebase is initialized in `main.dart` with proper error handling
- Anonymous authentication is used as fallback
- Crashlytics integration is configured for error reporting
- Analytics and performance monitoring are enabled

### Linting and Analysis
- The project uses `flutter_lints` with standard Flutter lint rules
- Analysis options are configured in `analysis_options.yaml`
- Follow the existing lint rules; avoid disabling lints unless absolutely necessary

### Internationalization
- **MANDATORY**: ALL user-facing text in widgets MUST use internationalization - NO EXCEPTIONS
- **ZERO TOLERANCE** for hardcoded/fixed text strings in any widget
- Support for English (`en`) and Portuguese (`pt`) locales
- Locale detection with device locale fallback to English
- Use `flutter gen-l10n` to regenerate localization files after changes
- Localization files are in ARB format in `lib/l10n/`
- Always use `AppLocalizations.of(context)` for any text displayed to users
- This requirement applies to ALL text: buttons, labels, hints, error messages, tooltips, etc.
- Refer to the "Widget Text and Internationalization" section in Code Conventions for detailed examples

## Development Best Practices

### Error Handling
- Implement comprehensive error handling, especially for Firebase operations
- Use try-catch blocks for async operations
- Provide meaningful error messages and fallback behaviors

### Performance
- Use `cached_network_image` for network images
- Implement proper widget disposal and cleanup
- Consider using `const` constructors where possible

### Security
- Firebase security rules are configured in `firestore.rules`
- Sensitive configuration is handled through Firebase configuration
- User authentication is properly managed through Firebase Auth

### Debugging
- Firebase Crashlytics is configured for production error tracking
- Use proper logging practices with the `logging` package
- Test thoroughly on both platforms (iOS/Android) before deployment
