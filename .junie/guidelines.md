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

📦 **New Standard Organization Pattern**

Each feature should follow this recommended structure for better separation of concerns and maintainability:

```
lib/
└── features/
    └── [feature_name]/          # Example: itinerary/
        ├── presentation/        # 🎨 UI layer - screens, widgets, UI state providers
        │   ├── screens/         # Main screens/pages
        │   │   └── trip_destination_screen.dart
        │   ├── widgets/         # Feature-specific UI components
        │   └── trip_planning_provider.dart  # UI state management (Riverpod providers)
        ├── data/                # 📊 Data layer - models, DTOs, repositories
        │   ├── models/          # Data models and DTOs
        │   │   └── trip_plan.dart
        │   └── repositories/    # Data access abstractions
        │       └── trip_repository.dart
        ├── service/             # 🔌 External integrations - Firebase, HTTP, APIs
        │   └── trip_agent_service.dart
        └── utils/               # 🛠️ Feature-specific helpers and formatters
```

🧠 **Component Roles and Placement:**

| Component Type | Location | Example | Purpose |
|---------------|----------|---------|---------|
| **Provider** | `presentation/` | `trip_planning_provider.dart` | UI state management (AsyncNotifier, StateNotifier) |
| **Repository** | `data/repositories/` | `TripRepository` with optional `ITripRepository` interface | Data access abstraction layer |
| **Model/DTO** | `data/models/` | `TripPlan`, `DestinationOption` | Data structures and transfer objects |
| **Service** | `service/` | `TripAgentService` | External API calls, Firebase Callable functions |
| **Screen/Page** | `presentation/screens/` | `TripDestinationScreen` | Main UI screens |
| **Widget** | `presentation/widgets/` | `TripCard`, `DestinationSelector` | Reusable UI components |
| **Utils** | `utils/` | `DateFormatter`, `TripValidator` | Feature-specific helpers |

💡 **Key Principles:**

- **Providers stay close to UI**: Even with Riverpod, keep providers in `presentation/` near the UI that consumes them
- **Repositories in data layer**: Abstract data access in `data/repositories/` following the repository pattern
- **Services for external calls**: Place Firebase, REST API, and external service calls in `service/`
- **Respect SOLID principles**: This structure supports Single Responsibility Principle without excessive complexity

**Legacy Structure Support:**
For existing features not yet migrated, the previous structure is still supported:
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

### File Naming Conventions (Mandatory)

**File names must be significant to their classes and roles:**

- File names should clearly indicate the purpose and type of the contained class
- Use descriptive names that reflect the class's responsibility
- Include the component type in the filename for clarity
- Follow snake_case convention for Dart files

**Examples of Good File Names:**

```
✅ Good Examples:
├── trip_planning_provider.dart      # Provider for trip planning state
├── firestore_trip_repository.dart   # Firestore implementation of trip repository
├── trip_destination_screen.dart     # Screen for trip destination selection
├── trip_card_widget.dart           # Widget for displaying trip cards
├── date_formatter_util.dart        # Utility for date formatting
├── trip_validation_service.dart    # Service for trip validation
├── user_profile_model.dart         # Model for user profile data
├── authentication_exception.dart   # Exception for authentication errors
```

**Examples of Poor File Names:**

```
❌ Poor Examples:
├── provider.dart                   # Too generic, unclear purpose
├── repository.dart                 # Doesn't specify which repository
├── screen.dart                     # Doesn't indicate which screen
├── widget.dart                     # Too vague, no context
├── utils.dart                      # Should be specific utility
├── service.dart                    # Doesn't specify service type
├── model.dart                      # Doesn't indicate data type
├── helper.dart                     # Too generic
```

**Naming Pattern Guidelines:**

| Component Type | Naming Pattern | Example |
|---------------|----------------|---------|
| **Provider** | `[feature]_[purpose]_provider.dart` | `trip_planning_provider.dart` |
| **Repository** | `[implementation]_[entity]_repository.dart` | `firestore_trip_repository.dart` |
| **Service** | `[purpose]_service.dart` | `trip_validation_service.dart` |
| **Model/DTO** | `[entity]_model.dart` or `[entity].dart` | `user_profile_model.dart`, `trip.dart` |
| **Screen/Page** | `[feature]_[purpose]_screen.dart` | `trip_destination_screen.dart` |
| **Widget** | `[purpose]_widget.dart` or `[purpose].dart` | `trip_card_widget.dart`, `trip_card.dart` |
| **Utility** | `[purpose]_util.dart` | `date_formatter_util.dart` |
| **Exception** | `[context]_exception.dart` | `authentication_exception.dart` |

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
```dart
Text(AppLocalizations.of(context)!.welcomeMessage)
```

**Prohibited:**
```dart
Text('Welcome to Travel Genie')  // Never do this
```

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
