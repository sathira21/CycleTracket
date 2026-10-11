import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';
import '../l10n/lang.dart';

class PastHistoryDialog extends StatefulWidget {
  const PastHistoryDialog({super.key});

  @override
  State<PastHistoryDialog> createState() => _PastHistoryDialogState();
}

class _PastHistoryDialogState extends State<PastHistoryDialog> {
  final List<TextEditingController> _controllers = [];
  final List<String> _monthNames = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final settingsBox = Hive.box<dynamic>('settings');
    List<dynamic> savedCycles = settingsBox.get('past_cycles_manual', defaultValue: []) as List<dynamic>;
    
    for (int i = 4; i >= 0; i--) {
      final targetMonth = DateTime(now.year, now.month - i, 1);
      _monthNames.add(months[targetMonth.month - 1]);
      
      String initialValue = '';
      if (savedCycles.length == 5) {
        initialValue = savedCycles[4 - i].toString();
      } else {
        // Fallback to average cycle length if no manual data yet
        int avg = settingsBox.get('profile_cycle_length', defaultValue: 28) as int;
        initialValue = avg.toString();
      }
      
      _controllers.add(TextEditingController(text: initialValue));
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    List<int> cycles = [];
    for (var c in _controllers) {
      cycles.add(int.tryParse(c.text) ?? 28);
    }
    Hive.box<dynamic>('settings').put('past_cycles_manual', cycles);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Lang>(valueListenable: LangService.current, builder: (context, lang, _) { return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Past Cycle History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter the cycle length (in days) for the past 5 months.',
              style: TextStyle(color: AppTheme.textLight),
            ),
            const SizedBox(height: 20),
            ...List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(_monthNames[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controllers[index],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          suffixText: 'days',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(t('save_data'), style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
      },
    );
  }
}
