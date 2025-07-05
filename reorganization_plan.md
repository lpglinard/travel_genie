# Travel Genie File Structure Reorganization Plan

## Overview
This plan addresses violations of the "one widget/model per file" rule as specified in the project guidelines.

## Identified Violations

### Model Files
1. **lib/features/trip/models/autocomplete_models.dart** (5 classes)
   - AutocompleteResponse
   - PlaceSuggestion  
   - PlacePrediction
   - PlaceText
   - StructuredFormat

2. **lib/features/user/models/traveler_profile_enums.dart** (6 enums)
   - TravelCompany
   - TravelBudget
   - AccommodationType
   - TravelInterest
   - GastronomicPreference
   - ItineraryStyle

### Widget Files
3. **lib/features/user/pages/traveler_profile_page.dart** (9 widget classes)
   - _IntroductionCard
   - _TravelCompanySection
   - _BudgetSection
   - _AccommodationSection
   - _InterestsSection
   - _GastronomicSection
   - _ItineraryStyleSection
   - _SectionCard
   - _ActionButtons

4. **lib/features/user/pages/profile_screen.dart** (6 widget classes)
   - ProfileView
   - LoginSection
   - UserIdentificationSection
   - TravelCoverSection
   - CoverItem
   - SettingsSection

5. **lib/features/trip/widgets/travel_partner_invite_widget.dart** (4 widget classes)
   - TravelPartnerInviteWidget
   - _TabButton
   - _FriendsListTab
   - _FriendListItem

6. **lib/features/trip/widgets/profile_completeness_widget.dart** (3 widget classes)
   - _LoadingProfileCompleteness
   - _ErrorProfileCompleteness
   - _ProfileCompletenessContent

7. **lib/features/trip/widgets/trip_overview_content.dart** (3 widget classes)
   - TripOverviewContent
   - _TripSummarySection
   - _ParticipantsSection

8. **lib/features/trip/widgets/trip_participants_avatars.dart** (3 widget classes)
   - TripParticipantsAvatars
   - _ParticipantAvatar
   - _MoreParticipantsIndicator

9. **lib/features/trip/widgets/date_range_picker_field.dart** (2 widget classes)
   - DateRangePickerField
   - _DateSelectionButton

## Reorganization Strategy

### For Model Files
- Split each model class into its own file
- Keep related models in the same directory
- Use descriptive filenames based on class names

### For Widget Files
- Extract private widget classes into separate files
- Create subdirectories for related widgets
- Maintain logical grouping by feature/functionality

## Implementation Plan

### Phase 1: Model Files Reorganization
1. Split autocomplete_models.dart into 5 separate files
2. Split traveler_profile_enums.dart into 6 separate files

### Phase 2: Widget Files Reorganization  
1. Extract widgets from traveler_profile_page.dart
2. Extract widgets from profile_screen.dart
3. Extract widgets from travel_partner_invite_widget.dart
4. Extract widgets from profile_completeness_widget.dart
5. Extract widgets from trip_overview_content.dart
6. Extract widgets from trip_participants_avatars.dart
7. Extract widgets from date_range_picker_field.dart

### Phase 3: Update Documentation
1. Update .junie/guidelines.md
2. Update codex-guidelines.md  
3. Update README.md

## Expected Directory Structure After Reorganization

```
lib/features/trip/models/
├── autocomplete_response.dart
├── place_suggestion.dart
├── place_prediction.dart
├── place_text.dart
└── structured_format.dart

lib/features/user/models/
├── travel_company.dart
├── travel_budget.dart
├── accommodation_type.dart
├── travel_interest.dart
├── gastronomic_preference.dart
└── itinerary_style.dart

lib/features/user/pages/traveler_profile/
├── traveler_profile_page.dart
├── introduction_card.dart
├── travel_company_section.dart
├── budget_section.dart
├── accommodation_section.dart
├── interests_section.dart
├── gastronomic_section.dart
├── itinerary_style_section.dart
├── section_card.dart
└── action_buttons.dart

lib/features/user/pages/profile/
├── profile_screen.dart
├── profile_view.dart
├── login_section.dart
├── user_identification_section.dart
├── travel_cover_section.dart
├── cover_item.dart
└── settings_section.dart
```

This reorganization will ensure compliance with the "one widget/model per file" rule while maintaining logical organization and feature-based architecture.