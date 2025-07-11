import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_genie/core/widgets/login_required_dialog.dart';
import 'package:travel_genie/features/challenge/models/challenge.dart';
import 'package:travel_genie/features/trip/models/cover_style.dart';
import 'package:travel_genie/features/trip/models/travel_cover.dart';
import 'package:travel_genie/features/trip/models/travel_cover_collection.dart';
import 'package:travel_genie/features/user/providers/user_providers.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

import '../services/profile_service.dart';
import '../widgets/profile/dark_mode_toggle_tile.dart';
import '../widgets/profile/delete_account_tile.dart';
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
      body: ProfileView(
        user: user,
        userData: userData,
        profileService: profileService,
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.user,
    required this.userData,
    required this.profileService,
  });

  final User? user;
  final dynamic userData;
  final ProfileService profileService;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user == null)
            const LoginSection()
          else
            UserIdentificationSection(user: user!, userData: userData),
          const SizedBox(height: 24),
          const TravelerProfileSummary(),
          const SizedBox(height: 24),
          TravelCoverSection(user: user, profileService: profileService),
          const SizedBox(height: 24),
          const SettingsSection(),
        ],
      ),
    );
  }
}

class LoginSection extends StatelessWidget {
  const LoginSection({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class UserIdentificationSection extends StatelessWidget {
  const UserIdentificationSection({
    super.key,
    required this.user,
    required this.userData,
  });

  final User user;
  final dynamic userData;

  @override
  Widget build(BuildContext context) {
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
}

class TravelCoverSection extends StatelessWidget {
  const TravelCoverSection({
    super.key,
    required this.user,
    required this.profileService,
  });

  final User? user;
  final ProfileService profileService;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.collections, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.travelCoverCollection,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (user == null)
          Card(
            child: InkWell(
              onTap: () async {
                await LoginRequiredDialog.show(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.collections, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.loginToAccessFullFeatures,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          StreamBuilder<TravelCoverCollection?>(
            stream: profileService.getUserTravelCovers(user!.uid),
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
                            AppLocalizations.of(context)!.unlockedCovers(
                              unlockedCovers.length,
                              totalCovers,
                            ),
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
                            return CoverItem(cover: cover);
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
}

class CoverItem extends StatelessWidget {
  const CoverItem({super.key, required this.cover});

  final TravelCover cover;

  @override
  Widget build(BuildContext context) {
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
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Divider(),
        SizedBox(height: 16),
        LanguageSettingsTile(),
        DarkModeToggleTile(),
        LogoutTile(),
        DeleteAccountTile(),
      ],
    );
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'create_account':
        return Icons.person_add;
      case 'complete_profile':
        return Icons.person;
      case 'create_trip':
        return Icons.flight_takeoff;
      case 'save_place':
        return Icons.place;
      case 'generate_itinerary':
        return Icons.auto_awesome;
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

  String _getRewardTypeDisplayName(String rewardType) {
    switch (rewardType) {
      case 'badge':
        return 'Conquista';
      case 'unlock':
        return 'Desbloqueio';
      case 'progress':
        return 'Progresso';
      default:
        return rewardType;
    }
  }

  String _getTimeRemainingText(Challenge challenge, int currentProgress) {
    if (challenge.isExpired) return 'Expirado';
    if (currentProgress >= challenge.goal) return 'Concluído';

    final remaining = challenge.timeRemaining;
    if (remaining.inDays > 0) {
      return '${remaining.inDays} dias restantes';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours} horas restantes';
    } else {
      return '${remaining.inMinutes} minutos restantes';
    }
  }
}
