import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/traveler_profile.dart';
import '../user_providers.dart';

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
      final service = ref.read(travelerProfileServiceProvider);
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
      final service = ref.read(travelerProfileServiceProvider);
      await service.saveProfile(updatedProfile);

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
            _IntroductionCard(message: l10n.travelerProfileIntroduction),
            const SizedBox(height: 24),

            // Travel Company Section
            _TravelCompanySection(
              selectedCompanies: _profile.travelCompany,
              onChanged: _updateTravelCompany,
            ),
            const SizedBox(height: 24),

            // Budget Section
            _BudgetSection(
              selectedBudget: _profile.budget,
              onChanged: _updateBudget,
            ),
            const SizedBox(height: 24),

            // Accommodation Section
            _AccommodationSection(
              selectedTypes: _profile.accommodationTypes,
              onChanged: _updateAccommodationTypes,
            ),
            const SizedBox(height: 24),

            // Interests Section
            _InterestsSection(
              selectedInterests: _profile.interests,
              onChanged: _updateInterests,
            ),
            const SizedBox(height: 24),

            // Gastronomic Preferences Section
            _GastronomicSection(
              selectedPreferences: _profile.gastronomicPreferences,
              onChanged: _updateGastronomicPreferences,
            ),
            const SizedBox(height: 24),

            // Itinerary Style Section
            _ItineraryStyleSection(
              selectedStyle: _profile.itineraryStyle,
              onChanged: _updateItineraryStyle,
            ),
            const SizedBox(height: 32),

            // Action Buttons
            _ActionButtons(
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

class _IntroductionCard extends StatelessWidget {
  const _IntroductionCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TravelCompanySection extends StatelessWidget {
  const _TravelCompanySection({
    required this.selectedCompanies,
    required this.onChanged,
  });

  final List<TravelCompany> selectedCompanies;
  final ValueChanged<List<TravelCompany>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _SectionCard(
      icon: Icons.group,
      title: l10n.travelerProfileTravelCompanyTitle,
      child: Column(
        children: TravelCompany.values.map((company) {
          final isSelected = selectedCompanies.contains(company);
          return CheckboxListTile(
            title: Text(_getTravelCompanyLabel(context, company)),
            value: isSelected,
            onChanged: (bool? value) {
              final newList = List<TravelCompany>.from(selectedCompanies);
              if (value == true) {
                newList.add(company);
              } else {
                newList.remove(company);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }

  String _getTravelCompanyLabel(BuildContext context, TravelCompany company) {
    final l10n = AppLocalizations.of(context)!;
    switch (company) {
      case TravelCompany.solo:
        return l10n.travelerProfileTravelCompanySolo;
      case TravelCompany.couple:
        return l10n.travelerProfileTravelCompanyCouple;
      case TravelCompany.familyWithChildren:
        return l10n.travelerProfileTravelCompanyFamily;
      case TravelCompany.friendsGroup:
        return l10n.travelerProfileTravelCompanyFriends;
    }
  }
}

class _BudgetSection extends StatelessWidget {
  const _BudgetSection({required this.selectedBudget, required this.onChanged});

  final TravelBudget? selectedBudget;
  final ValueChanged<TravelBudget> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _SectionCard(
      icon: Icons.attach_money,
      title: l10n.travelerProfileBudgetTitle,
      child: Column(
        children: TravelBudget.values.map((budget) {
          return RadioListTile<TravelBudget>(
            title: Text(_getBudgetLabel(context, budget)),
            value: budget,
            groupValue: selectedBudget,
            onChanged: (TravelBudget? value) {
              if (value != null) {
                onChanged(value);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  String _getBudgetLabel(BuildContext context, TravelBudget budget) {
    final l10n = AppLocalizations.of(context)!;
    switch (budget) {
      case TravelBudget.economic:
        return l10n.travelerProfileBudgetEconomic;
      case TravelBudget.moderate:
        return l10n.travelerProfileBudgetModerate;
      case TravelBudget.luxury:
        return l10n.travelerProfileBudgetLuxury;
    }
  }
}

class _AccommodationSection extends StatelessWidget {
  const _AccommodationSection({
    required this.selectedTypes,
    required this.onChanged,
  });

  final List<AccommodationType> selectedTypes;
  final ValueChanged<List<AccommodationType>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _SectionCard(
      icon: Icons.hotel,
      title: l10n.travelerProfileAccommodationTitle,
      child: Column(
        children: AccommodationType.values.map((type) {
          final isSelected = selectedTypes.contains(type);
          return CheckboxListTile(
            title: Text(_getAccommodationLabel(context, type)),
            value: isSelected,
            onChanged: (bool? value) {
              final newList = List<AccommodationType>.from(selectedTypes);
              if (value == true) {
                newList.add(type);
              } else {
                newList.remove(type);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }

  String _getAccommodationLabel(BuildContext context, AccommodationType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case AccommodationType.hostel:
        return l10n.travelerProfileAccommodationHostel;
      case AccommodationType.budgetHotel:
        return l10n.travelerProfileAccommodationBudgetHotel;
      case AccommodationType.comfortHotel:
        return l10n.travelerProfileAccommodationComfortHotel;
      case AccommodationType.resort:
        return l10n.travelerProfileAccommodationResort;
      case AccommodationType.apartment:
        return l10n.travelerProfileAccommodationApartment;
    }
  }
}

class _InterestsSection extends StatelessWidget {
  const _InterestsSection({
    required this.selectedInterests,
    required this.onChanged,
  });

  final List<TravelInterest> selectedInterests;
  final ValueChanged<List<TravelInterest>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _SectionCard(
      icon: Icons.favorite,
      title: l10n.travelerProfileInterestsTitle,
      child: Column(
        children: TravelInterest.values.map((interest) {
          final isSelected = selectedInterests.contains(interest);
          return CheckboxListTile(
            title: Text(_getInterestLabel(context, interest)),
            value: isSelected,
            onChanged: (bool? value) {
              final newList = List<TravelInterest>.from(selectedInterests);
              if (value == true) {
                newList.add(interest);
              } else {
                newList.remove(interest);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }

  String _getInterestLabel(BuildContext context, TravelInterest interest) {
    final l10n = AppLocalizations.of(context)!;
    switch (interest) {
      case TravelInterest.culture:
        return l10n.travelerProfileInterestsCulture;
      case TravelInterest.nature:
        return l10n.travelerProfileInterestsNature;
      case TravelInterest.nightlife:
        return l10n.travelerProfileInterestsNightlife;
      case TravelInterest.gastronomy:
        return l10n.travelerProfileInterestsGastronomy;
      case TravelInterest.shopping:
        return l10n.travelerProfileInterestsShopping;
      case TravelInterest.relaxation:
        return l10n.travelerProfileInterestsRelaxation;
    }
  }
}

class _GastronomicSection extends StatelessWidget {
  const _GastronomicSection({
    required this.selectedPreferences,
    required this.onChanged,
  });

  final List<GastronomicPreference> selectedPreferences;
  final ValueChanged<List<GastronomicPreference>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _SectionCard(
      icon: Icons.restaurant,
      title: l10n.travelerProfileGastronomicTitle,
      child: Column(
        children: GastronomicPreference.values.map((preference) {
          final isSelected = selectedPreferences.contains(preference);
          return CheckboxListTile(
            title: Text(_getGastronomicLabel(context, preference)),
            value: isSelected,
            onChanged: (bool? value) {
              final newList = List<GastronomicPreference>.from(
                selectedPreferences,
              );
              if (value == true) {
                newList.add(preference);
              } else {
                newList.remove(preference);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }

  String _getGastronomicLabel(
    BuildContext context,
    GastronomicPreference preference,
  ) {
    final l10n = AppLocalizations.of(context)!;
    switch (preference) {
      case GastronomicPreference.localFood:
        return l10n.travelerProfileGastronomicLocal;
      case GastronomicPreference.gourmetRestaurants:
        return l10n.travelerProfileGastronomicGourmet;
      case GastronomicPreference.dietaryRestrictions:
        return l10n.travelerProfileGastronomicDietary;
    }
  }
}

class _ItineraryStyleSection extends StatelessWidget {
  const _ItineraryStyleSection({
    required this.selectedStyle,
    required this.onChanged,
  });

  final ItineraryStyle? selectedStyle;
  final ValueChanged<ItineraryStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _SectionCard(
      icon: Icons.map,
      title: l10n.travelerProfileItineraryTitle,
      child: Column(
        children: ItineraryStyle.values.map((style) {
          return RadioListTile<ItineraryStyle>(
            title: Text(_getItineraryStyleLabel(context, style)),
            value: style,
            groupValue: selectedStyle,
            onChanged: (ItineraryStyle? value) {
              if (value != null) {
                onChanged(value);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  String _getItineraryStyleLabel(BuildContext context, ItineraryStyle style) {
    final l10n = AppLocalizations.of(context)!;
    switch (style) {
      case ItineraryStyle.detailed:
        return l10n.travelerProfileItineraryDetailed;
      case ItineraryStyle.spontaneous:
        return l10n.travelerProfileItinerarySpontaneous;
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onSave,
    required this.onSkip,
    this.isLoading = false,
  });

  final VoidCallback onSave;
  final VoidCallback onSkip;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onSave,
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(l10n.travelerProfileSaveButton),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: onSkip,
            child: Text(l10n.travelerProfileSkipButton),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
