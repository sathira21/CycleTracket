import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/lang_builder.dart';

/// S6 – Offline Library screen (placeholder until Phase 5).
class OfflineLibraryScreen extends StatelessWidget {
  const OfflineLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LangBuilder(
      builder: (context, lang) => Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppTopBar(title: t('library_title', lang: lang)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bookmark_outline,
                  color: AppTheme.textLight, size: 64),
              const SizedBox(height: 16),
              Text(
                t('library_empty_title', lang: lang),
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Full screen built in Phase 5',
                style: TextStyle(color: AppTheme.textLight, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
