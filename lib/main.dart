import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui_auth;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_providers.dart';
import 'firestore_service.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'config.dart';
import 'profile_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebase_ui_auth.FirebaseUIAuth.configureProviders([
      firebase_ui_auth.EmailAuthProvider(),
      GoogleProvider(clientId: googleClientId),
      AppleProvider(),
    ]);
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
      print('Usuário autenticado anonimamente');
    }
    print("Firebase inicializado com sucesso");
  } catch (error) {
    print("Erro ao inicializar o Firebase: $error");
  }
  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        localeProvider.overrideWithValue(
          StateController(
            prefs.containsKey('locale')
                ? Locale(prefs.getString('locale')!)
                : null,
          ),
        ),
        themeModeProvider.overrideWithValue(
          StateController(
            prefs.getBool('darkMode') == true
                ? ThemeMode.dark
                : ThemeMode.light,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

final counterProvider = StateProvider<int>((ref) => 0);
final authStateChangesProvider =
    StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    ref.listen(userDataProvider, (_, next) {
      final userData = next.valueOrNull;
      if (userData != null) {
        if (userData.locale != null) {
          ref.read(localeProvider.notifier).state = Locale(userData.locale!);
        }
        if (userData.darkMode != null) {
          ref.read(themeModeProvider.notifier).state =
              userData.darkMode! ? ThemeMode.dark : ThemeMode.light;
        }
        final prefs = ref.read(sharedPrefsProvider);
        if (userData.name != null) {
          prefs.setString('name', userData.name!);
        } else {
          prefs.remove('name');
        }
        if (userData.email != null) {
          prefs.setString('email', userData.email!);
        } else {
          prefs.remove('email');
        }
        if (userData.locale != null) {
          prefs.setString('locale', userData.locale!);
        } else {
          prefs.remove('locale');
        }
        if (userData.darkMode != null) {
          prefs.setBool('darkMode', userData.darkMode!);
        } else {
          prefs.remove('darkMode');
        }
      } else {
        final prefs = ref.read(sharedPrefsProvider);
        prefs.remove('name');
        prefs.remove('email');
        prefs.remove('locale');
        prefs.remove('darkMode');
      }
    });
    ref.listen<Locale?>(localeProvider, (_, next) {
      final prefs = ref.read(sharedPrefsProvider);
      if (next != null) {
        prefs.setString('locale', next.languageCode);
      } else {
        prefs.remove('locale');
      }
    });
    ref.listen<ThemeMode>(themeModeProvider, (_, next) {
      final prefs = ref.read(sharedPrefsProvider);
      prefs.setBool('darkMode', next == ThemeMode.dark);
    });
    ref.listen(authStateChangesProvider, (_, next) {
      final user = next.value;
      if (user != null && !user.isAnonymous) {
        ref.read(firestoreServiceProvider).upsertUser(
              user,
              locale: ref.read(localeProvider),
              darkMode: ref.read(themeModeProvider) == ThemeMode.dark,
            );
      }
    });
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('pt')],
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    final user = ref.watch(authStateChangesProvider).value;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.demoHomePageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: AppLocalizations.of(context)!.profileButtonTooltip,
            onPressed: () {
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null && !currentUser.isAnonymous) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => firebase_ui_auth.SignInScreen(
                      providers: [
                        firebase_ui_auth.EmailAuthProvider(),
                        GoogleProvider(clientId: googleClientId),
                        AppleProvider(),
                      ],
                      actions: [
                        firebase_ui_auth.AuthStateChangeAction<firebase_ui_auth.SignedIn>(
                          (context, state) {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                        ),
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
            Text(AppLocalizations.of(context)!.buttonMessage),
            Text('$counter', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterProvider.notifier).state++,
        key: const Key('increment'),
        tooltip: AppLocalizations.of(context)!.incrementTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}
