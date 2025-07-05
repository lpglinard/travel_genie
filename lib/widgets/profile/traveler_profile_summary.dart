import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/traveler_profile.dart';
import '../../services/profile_completeness_service.dart';
import '../../user_providers.dart';

class TravelerProfileSummary extends ConsumerWidget {
  const TravelerProfileSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(travelerProfileServiceProvider);

    return StreamBuilder<TravelerProfile?>(
      stream: service.streamProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final profile = snapshot.data;
        final completenessInfo = ProfileCompletenessService.calculateCompleteness(profile);

        return _buildSummaryCard(context, profile, completenessInfo);
      },
    );
  }


  Widget _buildSummaryCard(
    BuildContext context,
    TravelerProfile? profile,
    ProfileCompletenessInfo completenessInfo,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (profile == null || completenessInfo.percentage == 0.0) {
      return _buildEmptyProfileCard(context, l10n);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.travel_explore,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.travelerProfileTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/traveler-profile'),
                  child: Text(l10n.profileEdit),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Completion progress
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: completenessInfo.percentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completenessInfo.percentage == 1.0
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${completenessInfo.percentageAsInt}%',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Profile summary
            _buildProfileSummary(context, profile, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyProfileCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.travel_explore_outlined,
                  color: Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.travelerProfileTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.travelerProfileEmptyDescription,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/traveler-profile'),
                icon: const Icon(Icons.add),
                label: Text(l10n.travelerProfileCreateButton),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummary(
    BuildContext context,
    TravelerProfile profile,
    AppLocalizations l10n,
  ) {
    final summaryItems = <Widget>[];

    // Travel company
    if (profile.travelCompany.isNotEmpty) {
      final companies = profile.travelCompany
          .map((company) => _getTravelCompanyLabel(l10n, company))
          .join(', ');
      summaryItems.add(
        _buildSummaryItem(
          context,
          Icons.group,
          l10n.travelerProfileTravelCompanyTitle,
          companies,
        ),
      );
    }

    // Budget
    if (profile.budget != null) {
      summaryItems.add(
        _buildSummaryItem(
          context,
          Icons.attach_money,
          l10n.travelerProfileBudgetTitle,
          _getBudgetLabel(l10n, profile.budget!),
        ),
      );
    }

    // Interests (show first 2)
    if (profile.interests.isNotEmpty) {
      final interests = profile.interests
          .take(2)
          .map((interest) => _getInterestLabel(l10n, interest))
          .join(', ');
      final moreCount = profile.interests.length > 2
          ? profile.interests.length - 2
          : 0;
      final interestsText = moreCount > 0
          ? '$interests +$moreCount'
          : interests;

      summaryItems.add(
        _buildSummaryItem(
          context,
          Icons.favorite,
          l10n.travelerProfileInterestsTitle,
          interestsText,
        ),
      );
    }

    // Itinerary style
    if (profile.itineraryStyle != null) {
      summaryItems.add(
        _buildSummaryItem(
          context,
          Icons.map,
          l10n.travelerProfileItineraryTitle,
          _getItineraryStyleLabel(l10n, profile.itineraryStyle!),
        ),
      );
    }

    return Column(
      children: summaryItems
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: item,
            ),
          )
          .toList(),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTravelCompanyLabel(AppLocalizations l10n, TravelCompany company) {
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

  String _getBudgetLabel(AppLocalizations l10n, TravelBudget budget) {
    switch (budget) {
      case TravelBudget.economic:
        return l10n.travelerProfileBudgetEconomic;
      case TravelBudget.moderate:
        return l10n.travelerProfileBudgetModerate;
      case TravelBudget.luxury:
        return l10n.travelerProfileBudgetLuxury;
    }
  }

  String _getInterestLabel(AppLocalizations l10n, TravelInterest interest) {
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

  String _getItineraryStyleLabel(AppLocalizations l10n, ItineraryStyle style) {
    switch (style) {
      case ItineraryStyle.detailed:
        return l10n.travelerProfileItineraryDetailed;
      case ItineraryStyle.spontaneous:
        return l10n.travelerProfileItinerarySpontaneous;
    }
  }
}
