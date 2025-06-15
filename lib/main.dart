import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui_auth;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_providers.dart';
import 'firestore_service.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'config.dart';
import 'profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  runApp(const ProviderScope(child: MyApp()));
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
    ref.listen<UserData?>(userDataProvider, (_, next) {
      if (next != null && next.locale != null) {
        ref.read(localeProvider.notifier).state = Locale(next.locale!);
      }
    });
    ref.listen<User?>(authStateChangesProvider, (_, next) {
      if (next != null && !next.isAnonymous) {
        ref
            .read(firestoreServiceProvider)
            .upsertUser(next, ref.read(localeProvider));
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
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
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
