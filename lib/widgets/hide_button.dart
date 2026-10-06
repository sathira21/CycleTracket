import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';

/// The panic button (REQ-3.1). Solid, high-contrast and visually heavy: user
/// testing showed people hesitated when it blended into the header, so it must
/// never share the header's colour.
///
/// Kept as its own widget so it can be moved or turned into a FAB later.
class HideButton extends StatelessWidget {
  const HideButton({super.key, required this.onHide, this.label});

  final VoidCallback onHide;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final text = label ?? t('hide');
    return Semantics(
      button: true,
      label: text,
      excludeSemantics: true,
      child: Material(
        color: AppTheme.maroon,
        elevation: 4,
        shape: const StadiumBorder(
          side: BorderSide(color: Colors.white, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onHide,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.close, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
