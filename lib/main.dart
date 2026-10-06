import 'package:flutter/material.dart';
import 'services/local_storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
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
    );
  }
}
