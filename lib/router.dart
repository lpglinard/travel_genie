import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui;
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_genie/pages/trip_itinerary_page.dart';

import 'core/config/config.dart';
import 'l10n/app_localizations.dart';
import 'models/challenge.dart';
import 'models/place.dart';
import 'pages/create_trip_page.dart';
import 'pages/groups_page.dart';
import 'pages/home_page.dart';
import 'pages/my_trips_page.dart';
import 'pages/place_detail_page.dart';
import 'pages/profile_screen.dart' as app_profile;
import 'pages/search_results_page.dart';
import 'pages/traveler_profile_page.dart';
import 'providers/challenge_providers.dart';
import 'services/analytics_service.dart';
import 'trip/pages/new_trip_screen.dart';
import 'trip/pages/trip_details_page.dart';
import 'user_providers.dart';

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
          // Trips route
          GoRoute(
            path: '/trips',
            name: AppRoute.trips.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const MyTripsPage(),
            ),
          ),
          // Groups route
          GoRoute(
            path: '/groups',
            name: AppRoute.groups.name,
            pageBuilder: (context, state) =>
                NoTransitionPage(key: state.pageKey, child: const GroupsPage()),
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
          final extra = state.extra;
          final query = state.uri.queryParameters['query'] ?? '';

          // Handle both cases: when extra is a Place object directly or a Map
          Place? placeObj;
          int? heroTagIndex;

          if (extra is Place) {
            // If extra is a Place object directly
            placeObj = extra;
          } else if (extra is Map<String, dynamic>) {
            // If extra is a Map with a 'place' key
            placeObj = extra['place'];
            heroTagIndex = extra['heroTagIndex'];
          }

          // In a real implementation, you would fetch the place data
          // or pass it through state.extra
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
              child: PlaceDetailPage(
                place: placeObj!,
                heroTagIndex: heroTagIndex,
              ),
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
                // Only handle navigation if the pop wasn't already processed
                if (!didPop) {
                  // Navigate back to the previous screen
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    // If can't pop, go to home
                    context.go('/');
                  }
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
      // Traveler Profile screen route (outside the shell)
      GoRoute(
        path: '/traveler-profile',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                // Only handle navigation if the pop wasn't already processed
                if (!didPop) {
                  // Navigate back to the previous screen
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    // If can't pop, go to home
                    context.go('/');
                  }
                }
              },
              child: const TravelerProfilePage(),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      // Create Trip screen route (outside the shell) - Alternative path for CTA
      GoRoute(
        path: '/create-trip',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const CreateTripPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      // Trip Details screen route (outside the shell)
      GoRoute(
        path: '/trip/:id',
        pageBuilder: (context, state) {
          final tripId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                // Only handle navigation if the pop wasn't already processed
                if (!didPop) {
                  // Navigate back to the previous screen
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    // If can't pop, go to trips page
                    context.go('/trips');
                  }
                }
              },
              child: TripDetailsPage(tripId: tripId),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      // Trip Itinerary screen route (outside the shell)
      GoRoute(
        path: '/trip/:id/itinerary',
        pageBuilder: (context, state) {
          final tripId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: TripItineraryPage(tripId: tripId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      // Plan New Trip screen route (outside the shell)
      GoRoute(
        path: '/new-trip',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                // Only handle navigation if the pop wasn't already processed
                if (!didPop) {
                  // Navigate back to the previous screen
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    // If can't pop, go to home
                    context.go('/');
                  }
                }
              },
              child: const NewTripScreen(),
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
                // Only handle navigation if the pop wasn't already processed
                if (!didPop) {
                  // Navigate back to the previous screen
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    // If can't pop, go to home
                    context.go('/');
                  }
                }
              },
              child: firebase_ui.SignInScreen(
                providers: [
                  firebase_ui.EmailAuthProvider(),
                  GoogleProvider(
                    clientId: googleClientId,
                    iOSPreferPlist: true,
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
                  firebase_ui.AuthStateChangeAction<firebase_ui.AuthFailed>((context, state) {
                    final analyticsService = ref.read(analyticsServiceProvider);
                    analyticsService.logError(
                      errorType: 'auth_failed',
                      errorMessage: state.exception?.toString(),
                      screenName: 'signin_screen',
                    );
                  }),
                  firebase_ui.AuthStateChangeAction<firebase_ui.SignedIn>((context, firebase_ui.SignedIn state) async {
                    // Track login analytics
                    try {
                      final analyticsService = ref.read(analyticsServiceProvider);
                      final user = state.user;
                      final method = user != null && user.providerData.isNotEmpty
                          ? user.providerData.first.providerId
                          : 'unknown';
                      await analyticsService.logSignUp(method: method);
                    } catch (e) {
                      debugPrint('Error tracking sign-in analytics: $e');
                    }

                    // Track challenge progress for account creation
                    try {
                      final user = state.user;
                      if (user != null) {
                        final challengeActions = ref.read(challengeActionsProvider);
                        await challengeActions.markCompleted(user.uid, 'create_account');
                      }
                    } catch (e) {
                      // Log error but don't prevent navigation
                      debugPrint('Error tracking create_account challenge: $e');
                    }
                    context.go('/');
                  }),
                  firebase_ui.AuthStateChangeAction<firebase_ui.UserCreated>((BuildContext context, firebase_ui.UserCreated state) async {
                    // Track sign-up analytics
                    try {
                      final analyticsService = ref.read(analyticsServiceProvider);
                      final user = state.credential.user;
                      final method = user != null && user.providerData.isNotEmpty
                          ? user.providerData.first.providerId
                          : 'unknown';
                      await analyticsService.logSignUp(method: method);
                    } catch (e) {
                      debugPrint('Error tracking sign-up analytics: $e');
                    }

                    // Initialize user progress for all challenges
                    try {
                      final user = state.credential.user;
                      if (user != null) {
                        final challengeActions = ref.read(challengeActionsProvider);
                        final challengeIds = PredefinedChallenges.getActiveChallenges()
                            .map((challenge) => challenge.id)
                            .toList();
                        await challengeActions.initializeUserProgress(user.uid, challengeIds);
                      }
                    } catch (e) {
                      // Log error but don't prevent navigation
                      debugPrint('Error initializing user progress: $e');
                    }

                    // Track challenge progress for account creation
                    try {
                      final user = state.credential.user;
                      if (user != null) {
                        final challengeActions = ref.read(challengeActionsProvider);
                        await challengeActions.markCompleted(user.uid, 'create_account');
                      }
                    } catch (e) {
                      // Log error but don't prevent navigation
                      debugPrint('Error tracking create_account challenge: $e');
                    }

                    context.go('/');
                  }),
                  firebase_ui.AuthStateChangeAction<firebase_ui.CredentialLinked>((context, state) {
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
              icon: const Icon(Icons.person),
              label: AppLocalizations.of(context).navProfile,
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/trips')) return 2;
    if (location.startsWith('/profile')) return 3;
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
        destination = '/profile';
        screenName = 'profile_screen';
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
