import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_log.dart';

/// Storage for the Daily Log (symptom & mood tracker).
/// Provides full CRUD: save (create/update), read, and delete.
///
/// Call [init] after Hive has been initialised (see `main.dart`).
class DailyLogStore {
  DailyLogStore._();

  static const String boxName = 'daily_logs';
  static const int _adapterTypeId = 2;

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(_adapterTypeId)) {
      Hive.registerAdapter(DailyLogAdapter());
    }
    await Hive.openBox<DailyLog>(boxName);
  }

  static Box<DailyLog> get _box => Hive.box<DailyLog>(boxName);

  /// Rebuild UI when logs change.
  static ValueListenable<Box<DailyLog>> get listenable => _box.listenable();

  static int get count => _box.length;

  // ── CREATE / UPDATE ────────────────────────────────────────────────

  /// Saves (or overwrites) a log entry keyed by date (YYYY-MM-DD).
  static Future<void> saveLog(DailyLog log) async {
    await _box.put(_keyFor(log.date), log);
  }

  // ── READ ───────────────────────────────────────────────────────────

  /// Returns the log for a given date, or null if none exists.
  static DailyLog? getLogForDate(DateTime date) => _box.get(_keyFor(date));

  static bool hasLogForDate(DateTime date) =>
      _box.containsKey(_keyFor(date));

  /// All logs sorted newest first.
  static List<DailyLog> all() {
    final items = _box.values.toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  // ── DELETE ─────────────────────────────────────────────────────────

  /// Removes the log for a given date.
  static Future<void> deleteLog(DateTime date) => _box.delete(_keyFor(date));

  /// Clears all daily logs.
  static Future<void> clearAll() => _box.clear();

  // ── Helpers ────────────────────────────────────────────────────────

  static String _keyFor(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
