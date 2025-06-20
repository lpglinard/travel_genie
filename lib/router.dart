import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/config/config.dart';
import 'l10n/app_localizations.dart';
import 'pages/home_page.dart';
import 'pages/place_detail_page.dart';
import 'pages/profile_screen.dart' as app_profile;
import 'pages/search_results_page.dart';
import 'providers/user_providers.dart';
import 'services/analytics_service.dart';

// Navigation destinations
enum AppRoute { home, explore, trips, groups }

// Provider for the router
final routerProvider = Provider<GoRouter>((ref) {
  final analyticsService = ref.watch(analyticsServiceProvider);

  // Create a navigation observer that logs screen views to Firebase Analytics
  final observer = FirebaseAnalyticsObserver(
    analytics: FirebaseAnalytics.instance,
    nameExtractor: (RouteSettings settings) {
      // Extract a screen name from the route
      return settings.name;
    },
  );

  return GoRouter(
    initialLocation: '/',
    observers: [observer],
    redirect: (context, state) {
      // Add any global redirects here if needed
      return null;
    },
    routes: [
      // Shell route for the bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(
            location: state.uri.toString(),
            child: child,
          );
        },
        routes: [
          // Home route
          GoRoute(
            path: '/',
            name: AppRoute.home.name,
            pageBuilder: (context, state) =>
                NoTransitionPage(key: state.pageKey, child: const MyHomePage()),
          ),
          // Explore route
          GoRoute(
            path: '/explore',
            name: AppRoute.explore.name,
            pageBuilder: (context, state) {
              final query = state.uri.queryParameters['query'] ?? '';
              return NoTransitionPage(
                key: state.pageKey,
                child: SearchResultsPage(query: query),
              );
            },
          ),
          // Trips route (placeholder)
          GoRoute(
            path: '/trips',
            name: AppRoute.trips.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const Scaffold(body: Center(child: Text('My Trips'))),
            ),
          ),
          // Groups route (placeholder)
          GoRoute(
            path: '/groups',
            name: AppRoute.groups.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const Scaffold(body: Center(child: Text('Groups'))),
            ),
          ),
        ],
      ),
      // Place detail route (outside the shell)
      GoRoute(
        path: '/place/:id',
        pageBuilder: (context, state) {
          // This is a placeholder - we'll need to update this to load the place
          // from the provider or pass it through state.extra
          final placeId = state.pathParameters['id']!;
          final place = state.extra as Map<String, dynamic>?;
          final query = state.uri.queryParameters['query'] ?? '';

          // In a real implementation, you would fetch the place data
          // or pass it through state.extra
          return CustomTransitionPage(
            key: state.pageKey,
            child: PlaceDetailPage(
              place: place?['place'],
              heroTagIndex: place?['heroTagIndex'],
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      // Profile screen route (outside the shell)
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                // Navigate back to the previous screen
                if (context.canPop()) {
                  context.pop();
                } else {
                  // If can't pop, go to home
                  context.go('/');
                }
              },
              child: const app_profile.ProfileScreen(),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      // Sign-in screen route (outside the shell)
      GoRoute(
        path: '/signin',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                // Navigate back to the previous screen
                if (context.canPop()) {
                  context.pop();
                } else {
                  // If can't pop, go to home
                  context.go('/');
                }
              },
              child: SignInScreen(
                providers: [
                  EmailAuthProvider(),
                  GoogleProvider(
                    clientId: googleClientId,
                    scopes: ['email', 'profile', 'openid'],
                  ),
                  AppleProvider(),
                ],
                headerBuilder: (context, constraints, _) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset('images/odsy_main.png'),
                    ),
                  );
                },
                actions: [
                  AuthStateChangeAction<SignedIn>((context, state) {
                    context.go('/');
                  }),
                  AuthStateChangeAction<UserCreated>((context, state) {
                    context.go('/');
                  }),
                  AuthStateChangeAction<CredentialLinked>((context, state) {
                    context.go('/');
                  }),
                ],
              ),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
    ],
  );
});

// Scaffold with bottom navigation bar
class ScaffoldWithNavBar extends ConsumerWidget {
  final String location;
  final Widget child;

  const ScaffoldWithNavBar({
    Key? key,
    required this.location,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsService = ref.watch(analyticsServiceProvider);
    final isHome = location == '/' || location == '';

    return PopScope(
      canPop: isHome, // Only allow system back to close app when on home screen
      onPopInvoked: (didPop) {
        // If we're on a non-home screen and the pop wasn't handled by the system
        if (!isHome && !didPop) {
          // Navigate to home screen when back button is pressed on other screens
          context.go('/');
        }
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _calculateSelectedIndex(location),
          type: BottomNavigationBarType.fixed,
          onTap: (index) => _onItemTapped(index, context, analyticsService),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: AppLocalizations.of(context).navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              label: AppLocalizations.of(context).navExplore,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map),
              label: AppLocalizations.of(context).navMyTrips,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.group),
              label: AppLocalizations.of(context).navGroups,
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/trips')) return 2;
    if (location.startsWith('/groups')) return 3;
    return 0; // Default to home
  }

  void _onItemTapped(
    int index,
    BuildContext context,
    AnalyticsService analyticsService,
  ) {
    String destination;
    String screenName;

    switch (index) {
      case 0:
        destination = '/';
        screenName = 'home_screen';
        break;
      case 1:
        destination = '/explore';
        screenName = 'explore_screen';
        break;
      case 2:
        destination = '/trips';
        screenName = 'trips_screen';
        break;
      case 3:
        destination = '/groups';
        screenName = 'groups_screen';
        break;
      default:
        destination = '/';
        screenName = 'home_screen';
    }

    // Log screen view to analytics
    FirebaseAnalytics.instance.logScreenView(screenName: screenName);

    // Navigate to the destination
    context.go(destination);
  }
}
