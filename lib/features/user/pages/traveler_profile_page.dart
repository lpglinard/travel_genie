import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_genie/features/user/models/traveler_profile.dart';
import 'package:travel_genie/features/user/models/traveler_profile_enums.dart';
import 'package:travel_genie/features/user/providers/user_providers.dart' as user_providers;
import 'package:travel_genie/features/user/widgets/profile/accommodation_section.dart';
import 'package:travel_genie/features/user/widgets/profile/action_buttons.dart';
import 'package:travel_genie/features/user/widgets/profile/budget_section.dart';
import 'package:travel_genie/features/user/widgets/profile/gastronomic_section.dart';
import 'package:travel_genie/features/user/widgets/profile/interests_section.dart';
import 'package:travel_genie/features/user/widgets/profile/introduction_card.dart';
import 'package:travel_genie/features/user/widgets/profile/itinerary_style_section.dart';
import 'package:travel_genie/features/user/widgets/profile/travel_company_section.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

class TravelerProfilePage extends ConsumerStatefulWidget {
  const TravelerProfilePage({super.key});

  @override
  ConsumerState<TravelerProfilePage> createState() =>
      _TravelerProfilePageState();
}

class _TravelerProfilePageState extends ConsumerState<TravelerProfilePage> {
  TravelerProfile _profile = const TravelerProfile();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final service = ref.read(user_providers.travelerProfileServiceProvider);
      final existingProfile = await service.getProfile();
      if (existingProfile != null && mounted) {
        setState(() {
          _profile = existingProfile;
        });
      }
    } catch (e) {
      // Handle error silently - user might not be authenticated
      debugPrint('Error loading traveler profile: $e');
    }
  }

  void _updateTravelCompany(List<TravelCompany> companies) {
    setState(() {
      _profile = _profile.copyWith(travelCompany: companies);
    });
  }

  void _updateBudget(TravelBudget budget) {
    setState(() {
      _profile = _profile.copyWith(budget: budget);
    });
  }

  void _updateAccommodationTypes(List<AccommodationType> types) {
    setState(() {
      _profile = _profile.copyWith(accommodationTypes: types);
    });
  }

  void _updateInterests(List<TravelInterest> interests) {
    setState(() {
      _profile = _profile.copyWith(interests: interests);
    });
  }

  void _updateGastronomicPreferences(List<GastronomicPreference> preferences) {
    setState(() {
      _profile = _profile.copyWith(gastronomicPreferences: preferences);
    });
  }

  void _updateItineraryStyle(ItineraryStyle style) {
    setState(() {
      _profile = _profile.copyWith(itineraryStyle: style);
    });
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final updatedProfile = _profile.copyWith(
        createdAt: _profile.createdAt ?? now,
        updatedAt: now,
      );

      // Get the service and save profile
      final service = ref.read(user_providers.travelerProfileServiceProvider);
      await service.saveProfile(updatedProfile);

      // Track challenge progress for profile completion
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && updatedProfile.isComplete) {
          final challengeActions = ref.read(user_providers.challengeActionsProvider);
          await challengeActions.markCompleted(user.uid, 'complete_profile');
          debugPrint(
            '[DEBUG_LOG] Complete profile challenge marked as completed for user ${user.uid}',
          );
        }
      } catch (e) {
        // Log error but don't prevent the profile save success flow
        debugPrint('Error tracking complete_profile challenge: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.travelerProfileSaved),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorGeneric(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _skipStep() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.travelerProfileTitle), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction message
            IntroductionCard(message: l10n.travelerProfileIntroduction),
            const SizedBox(height: 24),

            // Travel Company Section
            TravelCompanySection(
              selectedCompanies: _profile.travelCompany,
              onChanged: _updateTravelCompany,
            ),
            const SizedBox(height: 24),

            // Budget Section
            BudgetSection(
              selectedBudget: _profile.budget,
              onChanged: _updateBudget,
            ),
            const SizedBox(height: 24),

            // Accommodation Section
            AccommodationSection(
              selectedTypes: _profile.accommodationTypes,
              onChanged: _updateAccommodationTypes,
            ),
            const SizedBox(height: 24),

            // Interests Section
            InterestsSection(
              selectedInterests: _profile.interests,
              onChanged: _updateInterests,
            ),
            const SizedBox(height: 24),

            // Gastronomic Preferences Section
            GastronomicSection(
              selectedPreferences: _profile.gastronomicPreferences,
              onChanged: _updateGastronomicPreferences,
            ),
            const SizedBox(height: 24),

            // Itinerary Style Section
            ItineraryStyleSection(
              selectedStyle: _profile.itineraryStyle,
              onChanged: _updateItineraryStyle,
            ),
            const SizedBox(height: 32),

            // Action Buttons
            ActionButtons(
              onSave: _savePreferences,
              onSkip: _skipStep,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
