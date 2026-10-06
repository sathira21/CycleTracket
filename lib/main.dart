import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/local_storage_service.dart';
import 'services/saved_articles_store.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/widget_kit_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Offline-first: fonts are bundled in assets/google_fonts, never fetched at runtime.
  GoogleFonts.config.allowRuntimeFetching = false;
  await LocalStorageService.init();
  await SavedArticlesStore.init();
  runApp(const CycleCareApp());
}

class CycleCareApp extends StatelessWidget {
  const CycleCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cycle Care',
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        // Debug-only widget kit screen (Phase 1 accept criteria).
        if (kDebugMode) '/kit': (_) => const WidgetKitScreen(),
      },
    );
  }
}
