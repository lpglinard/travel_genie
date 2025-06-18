import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui_auth;
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../config.dart';
import '../l10n/app_localizations.dart';
import '../profile_screen.dart';
import '../user_providers.dart';

final counterProvider = StateProvider<int>((ref) => 0);

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context).demoHomePageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: AppLocalizations.of(context).profileButtonTooltip,
            onPressed: () {
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null && !currentUser.isAnonymous) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'profile'),
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'sign_in'),
                    builder: (context) => firebase_ui_auth.SignInScreen(
                      providers: [
                        firebase_ui_auth.EmailAuthProvider(),
                        GoogleProvider(clientId: googleClientId),
                        AppleProvider(),
                      ],
                      actions: [
                        firebase_ui_auth.AuthStateChangeAction<
                          firebase_ui_auth.UserCreated
                        >((context, state) {
                          final analytics = ref.read(analyticsServiceProvider);
                          analytics.logSignUp(
                            method:
                                state.credential.credential?.providerId ??
                                'unknown',
                          );
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        }),
                        firebase_ui_auth.AuthStateChangeAction<
                          firebase_ui_auth.SignedIn
                        >((context, state) {
                          final analytics = ref.read(analyticsServiceProvider);
                          final providerId =
                              state.user?.providerData.isNotEmpty == true
                              ? state.user!.providerData.first.providerId
                              : 'unknown';
                          analytics.logLogin(method: providerId);
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        }),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context).buttonMessage),
            Text('$counter', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final notifier = ref.read(counterProvider.notifier);
          if (notifier.state >= 4) {
            FirebaseCrashlytics.instance.crash();
          } else {
            notifier.state++;
          }
        },
        key: const Key('increment'),
        tooltip: AppLocalizations.of(context).incrementTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}
