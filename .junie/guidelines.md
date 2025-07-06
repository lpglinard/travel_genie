# Travel Genie Development Guidelines

## Quick Setup

### Initial Setup
1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Firebase Configuration**
   - Firebase handles authentication, Firestore, analytics, performance monitoring, and crashlytics
   - Configuration: `lib/firebase_options.dart`

3. **Localization**
   - Supports English and Portuguese
   - Files: `lib/l10n/`
   - After changes: `flutter gen-l10n`

4. **Custom Fonts**
   - Nunito font family (multiple weights)
   - Location: `fonts/` directory

### Build Commands
- **Development:** `flutter run`
- **Release (Android):** `flutter build apk --release`
- **Release (iOS):** `flutter build ios --release`
- **Web:** `flutter build web`
- **Testing:** `flutter test`

## Testing

### Configuration
- Unit tests: `flutter_test`
- Integration tests: `integration_test`
- Network image mocking: `network_image_mock`
- SharedPreferences mocking available

### Running Tests
- All tests: `flutter test`
- Specific file: `flutter test test/filename_test.dart`
- Integration tests: `flutter test integration_test/`

### Test Structure Template
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

## Project Architecture

### Structure Overview
```
lib/
├── app.dart                 # Main app configuration
├── main.dart                # Entry point
├── router.dart              # App routing
├── providers/               # Global providers
├── core/                    # Shared functionality
│   ├── config/              # Configuration
│   ├── extensions/          # Dart extensions
│   ├── models/              # Shared data models
│   ├── pages/               # Core UI screens
│   ├── providers/           # Core providers
│   ├── services/            # Core services
│   ├── theme/               # Theming
│   ├── utils/               # Utility functions
│   └── widgets/             # Shared UI components
├── features/                # Feature-specific code
│   ├── authentication/      # User authentication
│   ├── challenge/           # Challenges and badges
│   ├── place/               # Places and locations
│   ├── search/              # Search functionality
│   ├── social/              # Social features
│   ├── trip/                # Trip management
│   └── user/                # User management
└── l10n/                    # Localization files
```

### Feature Structure
Each feature follows this pattern:
```
features/[feature_name]/
├── models/          # Feature-specific data models
├── pages/           # Feature UI screens
├── providers/       # Feature state management
├── services/        # Feature business logic
└── widgets/         # Feature-specific widgets
```

### Key Architectural Rules

1. **One Widget/Model Per File** - Strictly enforced
2. **Feature-Based Organization** - Group related functionality
3. **Separation of Concerns** - Abstract classes and implementations in separate files

**Example:**
```
services/
├── trip_repository.dart            # Abstract class
├── firestore_trip_repository.dart  # Implementation
```

## Coding Standards

### SOLID Principles (Mandatory)

**All code must follow SOLID principles:**

- **Single Responsibility:** Each class has one reason to change
- **Open/Closed:** Open for extension, closed for modification
- **Liskov Substitution:** Subclasses must be substitutable for base classes
- **Interface Segregation:** Prefer small, focused interfaces
- **Dependency Inversion:** Depend on abstractions, not implementations

### Services Pattern
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
- Use immutable classes with `final` fields
- Implement robust JSON serialization
- Handle null safety properly

```dart
class Place {
  const Place({
    required this.placeId,
    required this.displayName,
    this.category,
  });

  final String placeId;
  final String displayName;
  final PlaceCategory? category;

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeId: json['placeId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      category: json['category'] != null 
          ? PlaceCategory.fromString(json['category']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'placeId': placeId,
    'displayName': displayName,
    if (category != null) 'category': category!.name,
  };
}
```

### Widget Guidelines
- **Avoid** private builder methods
- **Prefer** reusable widget classes
- Use builder methods only for trivial UI elements

**Discouraged:**
```dart
Widget _buildDraggablePlace(BuildContext context, Place place) {
  return LongPressDraggable<DraggedPlaceData>(/* ... */);
}
```

**Recommended:**
```dart
class DraggablePlace extends StatelessWidget {
  const DraggablePlace({super.key, required this.place});
  final Place place;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<DraggedPlaceData>(/* ... */);
  }
}
```

## Internationalization

### Rules (Mandatory)
- **ALL user-facing text must use internationalization**
- **NO hardcoded strings in widgets**
- Support: English (`en`) and Portuguese (`pt`)
- Use `AppLocalizations.of(context)!` for all user-visible strings

**Required:**
- Use `Text(AppLocalizations.of(context)!.welcomeMessage)`

**Prohibited:**
- Never use hardcoded strings like `Text('Welcome to Travel Genie')`

## Import Guidelines

- Use `package:` imports for files outside current directory
- Use relative imports only for files in same directory
- Never use `../../../` imports

**Correct:**
```dart
import 'package:travel_genie/features/trip/models/trip.dart';
import 'trip_cover_image.dart';  // Same directory only
```

## Best Practices

### Error Handling
- Use try-catch for async operations
- Provide meaningful error messages
- Implement fallback behavior

### Performance
- Use `cached_network_image` for images
- Dispose resources properly
- Prefer `const` constructors

### Security
- Firebase security rules: `firestore.rules`
- Firebase Auth handles authentication
- Sensitive config via Firebase

### Debugging
- Firebase Crashlytics for error tracking
- Use `logging` package
- Test on both iOS and Android

## Current Features

The app currently includes these features:
- **Authentication:** User login/registration
- **Challenge:** Badges and achievements
- **Place:** Location management and discovery
- **Search:** Place and trip search
- **Social:** User interactions and sharing
- **Trip:** Trip planning and management
- **User:** Profile and preferences management

Each feature follows the established architecture patterns and maintains the "one widget/model per file" rule.
