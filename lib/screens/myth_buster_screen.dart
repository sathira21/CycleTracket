import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/lang_builder.dart';

/// S7 – Myth Buster quiz screen (placeholder until Phase 6).
class MythBusterScreen extends StatelessWidget {
  const MythBusterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LangBuilder(
      builder: (context, lang) => Scaffold(
        backgroundColor: AppTheme.maroon,
        appBar: AppTopBar(
          title: t('quiz_title', lang: lang),
          dark: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.psychology, color: Colors.white54, size: 64),
              const SizedBox(height: 16),
              Text(
                t('quiz_title', lang: lang),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Coming in Phase 6',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
