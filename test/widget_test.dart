import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:travel_genie/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:travel_genie/firebase_options.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp(
      name: 'test-widget',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('home page displays search field', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('Where'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
