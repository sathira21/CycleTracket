import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'screens/privacy_lock_screen.dart';
import 'screens/widget_kit_screen.dart';
import 'services/local_storage_service.dart';
import 'services/pin_service.dart';
import 'services/saved_articles_store.dart';
import 'services/session_state.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Offline-first: fonts are bundled in assets/google_fonts, never fetched at runtime.
  GoogleFonts.config.allowRuntimeFetching = false;

  await LocalStorageService.init();
  await SavedArticlesStore.init();

  // Dev/test seed: flutter run --dart-define=DEMO_PIN=1234
  const demoPin = String.fromEnvironment('DEMO_PIN');
  final pinService = await MockPinService.init(
    demoPin: demoPin.isNotEmpty ? demoPin : null,
  );

  runApp(CycleCareApp(pinService: pinService));
}

class CycleCareApp extends StatelessWidget {
  const CycleCareApp({super.key, required this.pinService});

  final PinService pinService;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SessionState>(
      create: (_) => SessionState(pinService: pinService),
      child: MaterialApp(
        title: 'Cycle Care',
        theme: AppTheme.lightTheme,
        // Every cold start shows the lock screen (Phase 2).
        home: const PrivacyLockScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          // Debug-only widget kit screen (Phase 1 accept criteria).
          if (kDebugMode) '/kit': (_) => const WidgetKitScreen(),
        },
      ),
    );
  }
}

