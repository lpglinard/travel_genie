import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/badge.dart' as badge_model;
import '../models/challenge.dart';
import '../models/travel_cover.dart';
import '../services/profile_service.dart';
import '../user_providers.dart';
import '../widgets/profile/dark_mode_toggle_tile.dart';
import '../widgets/profile/language_settings_tile.dart';
import '../widgets/profile/logout_tile.dart';
import '../widgets/profile/traveler_profile_summary.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final userData = ref.watch(userDataProvider).valueOrNull;
    final profileService = ref.watch(profileServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileTitle),
        elevation: 0,
      ),
      body: _buildUnifiedView(context, user, userData, profileService),
    );
  }

  Widget _buildUnifiedView(
    BuildContext context,
    User? user,
    dynamic userData,
    ProfileService profileService,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section - Login for Unauthenticated, User Info for Authenticated
          if (user == null)
            _buildLoginSection(context)
          else
            _buildUserIdentificationSection(context, user, userData),
          const SizedBox(height: 24),

          // Traveler Profile Summary Section
          const TravelerProfileSummary(),
          const SizedBox(height: 24),

          // Show user-specific sections only for authenticated users
          if (user != null) ...[
            // Badges and Achievements Section
            _buildBadgesSection(
              context,
              user.uid,
              profileService,
            ),
            const SizedBox(height: 24),

            // Travel Cover Collection Section
            _buildTravelCoverSection(
              context,
              user.uid,
              profileService,
            ),
            const SizedBox(height: 24),

            // Challenges Section
            _buildChallengesSection(
              context,
              user.uid,
              profileService,
            ),
            const SizedBox(height: 24),
          ],

          // Settings Section
          _buildSettingsSection(),
        ],
      ),
    );
  }

  Widget _buildLoginSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person_outline, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.guest,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.loginToAccessFullFeatures,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to sign-in screen
                context.go('/signin');
              },
              icon: const Icon(Icons.login),
              label: Text(AppLocalizations.of(context)!.loginRegisterButton),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserIdentificationSection(
    BuildContext context,
    User user,
    dynamic userData,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL == null
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData?.name ??
                        user.displayName ??
                        user.email ??
                        AppLocalizations.of(context)!.user,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (userData?.email != null || user.email != null)
                    Text(
                      userData?.email ?? user.email!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection(
    BuildContext context,
    String userId,
    ProfileService profileService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.achievements,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<badge_model.Badge>>(
          stream: profileService.getUserBadges(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final badges = snapshot.data ?? [];
            final unlockedBadges = badges
                .where((badge) => badge.isUnlocked)
                .toList();
            final lockedBadges = badges
                .where((badge) => !badge.isUnlocked)
                .toList();

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.unlockedBadges(unlockedBadges.length, badges.length),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${badges.isNotEmpty ? ((unlockedBadges.length / badges.length) * 100).toInt() : 0}%',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: badges.isNotEmpty
                          ? unlockedBadges.length / badges.length
                          : 0,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: badges.length,
                      itemBuilder: (context, index) {
                        final badge = badges[index];
                        return _buildBadgeItem(context, badge);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBadgeItem(BuildContext context, badge_model.Badge badge) {
    final translatedName = _getTranslatedBadgeName(context, badge.name);
    final translatedDescription = _getTranslatedBadgeDescription(
      context,
      badge.description,
    );

    return Tooltip(
      message: '$translatedName\n$translatedDescription',
      child: Container(
        decoration: BoxDecoration(
          color: badge.isUnlocked ? Colors.amber[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: badge.isUnlocked ? Colors.amber : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconFromName(badge.iconName),
              size: 24,
              color: badge.isUnlocked ? Colors.amber[700] : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              translatedName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: badge.isUnlocked ? Colors.amber[700] : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getTranslatedBadgeName(BuildContext context, String key) {
    final appLocalizations = AppLocalizations.of(context)!;
    switch (key) {
      case 'badgesFirstTripName':
        return appLocalizations.badgesFirstTripName;
      case 'badgesFirstLoginName':
        return appLocalizations.badgesFirstLoginName;
      case 'badgesFirstInviteName':
        return appLocalizations.badgesFirstInviteName;
      case 'badgesFirstAiCoverName':
        return appLocalizations.badgesFirstAiCoverName;
      default:
        return key; // Fallback to the key if no translation found
    }
  }

  String _getTranslatedBadgeDescription(BuildContext context, String key) {
    final appLocalizations = AppLocalizations.of(context)!;
    switch (key) {
      case 'badgesFirstTripDescription':
        return appLocalizations.badgesFirstTripDescription;
      case 'badgesFirstLoginDescription':
        return appLocalizations.badgesFirstLoginDescription;
      case 'badgesFirstInviteDescription':
        return appLocalizations.badgesFirstInviteDescription;
      case 'badgesFirstAiCoverDescription':
        return appLocalizations.badgesFirstAiCoverDescription;
      default:
        return key; // Fallback to the key if no translation found
    }
  }

  Widget _buildTravelCoverSection(
    BuildContext context,
    String userId,
    ProfileService profileService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.collections, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              'Coleção de Capas',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<TravelCoverCollection?>(
          stream: profileService.getUserTravelCovers(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final collection = snapshot.data;
            final unlockedCovers = collection?.unlockedCovers ?? [];
            final totalCovers = collection?.covers.length ?? 0;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Desbloqueadas: ${unlockedCovers.length}/$totalCovers',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${collection?.completionPercentage.toInt() ?? 0}%',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (collection?.completionPercentage ?? 0) / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (unlockedCovers.isEmpty)
                      Text(
                        AppLocalizations.of(context)!.noCoversUnlockedYet,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: unlockedCovers.length,
                        itemBuilder: (context, index) {
                          final cover = unlockedCovers[index];
                          return _buildCoverItem(context, cover);
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCoverItem(BuildContext context, TravelCover cover) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                color: Colors.grey[200],
              ),
              child: cover.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: Image.network(
                        cover.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image),
                      ),
                    )
                  : const Center(child: Icon(Icons.image, size: 40)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              cover.style.displayName,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesSection(
    BuildContext context,
    String userId,
    ProfileService profileService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flag, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.activeChallenges,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Challenge>>(
          stream: profileService.getActiveChallenges(userId),
          builder: (context, challengeSnapshot) {
            return StreamBuilder<Map<String, int>>(
              stream: profileService.getUserChallengeProgress(userId),
              builder: (context, progressSnapshot) {
                if (challengeSnapshot.connectionState ==
                        ConnectionState.waiting ||
                    progressSnapshot.connectionState ==
                        ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final challenges = challengeSnapshot.data ?? [];
                final progress = progressSnapshot.data ?? {};

                if (challenges.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Nenhum desafio ativo no momento.\nNovos desafios chegam semanalmente!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return Column(
                  children: challenges.map((challenge) {
                    final currentProgress = progress[challenge.id] ?? 0;
                    final updatedChallenge = challenge.copyWith(
                      currentProgress: currentProgress,
                    );
                    return _buildChallengeItem(context, updatedChallenge);
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildChallengeItem(BuildContext context, Challenge challenge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getIconFromName(challenge.type.iconName)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    challenge.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  challenge.timeRemainingText,
                  style: TextStyle(
                    color: challenge.isExpired ? Colors.red : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: challenge.progressPercentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      challenge.isCompleted ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${challenge.currentProgress}/${challenge.targetValue}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  challenge.rewardType == RewardType.badge
                      ? Icons.emoji_events
                      : Icons.collections,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Recompensa: ${challenge.rewardType.displayName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        const LanguageSettingsTile(),
        const DarkModeToggleTile(),
        const LogoutTile(),
      ],
    );
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'flight_takeoff':
        return Icons.flight_takeoff;
      case 'login':
        return Icons.login;
      case 'group_add':
        return Icons.group_add;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'add_location':
        return Icons.add_location;
      case 'place':
        return Icons.place;
      case 'checklist':
        return Icons.checklist;
      default:
        return Icons.star;
    }
  }
}
