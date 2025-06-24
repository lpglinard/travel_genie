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
- **Development build**: `flutter run`
- **Release build**: `flutter build apk --release` (Android) or `flutter build ios --release` (iOS)
- **Web build**: `flutter build web`

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
├── config.dart             # Configuration settings
├── core/                   # Core functionality
├── features/               # Feature-specific code
├── l10n/                   # Localization files
├── models/                 # Data models
├── pages/                  # UI screens/pages
├── providers/              # Riverpod state management
├── services/               # Business logic services
├── utils/                  # Utility functions
└── widgets/                # Reusable UI components
```

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
- Support for English (`en`) and Portuguese (`pt`) locales
- Locale detection with device locale fallback to English
- Use `flutter gen-l10n` to regenerate localization files after changes
- Localization files are in ARB format in `lib/l10n/`

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
