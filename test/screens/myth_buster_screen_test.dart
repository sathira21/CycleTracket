import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:cycle_care/models/cycle_entry.dart';
import 'package:cycle_care/models/saved_article.dart';
import 'package:cycle_care/screens/main_screen.dart';
import 'package:cycle_care/screens/myth_buster_screen.dart';
import 'package:cycle_care/services/pin_service.dart';
import 'package:cycle_care/services/saved_articles_store.dart';
import 'package:cycle_care/services/session_state.dart';
import 'package:cycle_care/widgets/app_toast.dart';
import 'package:cycle_care/widgets/hide_button.dart';

class _FakePinService implements PinService {
  @override
  Future<bool> isSet() async => true;
  @override
  Future<bool> verify(String pin) async => true;
  @override
  Future<void> set(String pin) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionState sessionState;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_myth_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CycleEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SavedArticleAdapter());
    }
    await Hive.openBox<CycleEntry>('cycle_entries');
    await Hive.openBox<SavedArticle>(SavedArticlesStore.boxName);
    await Hive.openBox<dynamic>('settings');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    AppToast.reset();
    await Hive.box<CycleEntry>('cycle_entries').clear();
    await Hive.box<SavedArticle>(SavedArticlesStore.boxName).clear();
    await Hive.box<dynamic>('settings').clear();
    sessionState = SessionState(pinService: _FakePinService());
    await sessionState.tryUnlock('1234');
  });

  tearDown(() {
    AppToast.reset();
    sessionState.dispose();
  });

  Widget createSubject({bool shuffle = false}) {
    return ChangeNotifierProvider<SessionState>.value(
      value: sessionState,
      child: MaterialApp(
        home: MythBusterScreen(shuffleQuestions: shuffle),
      ),
    );
  }

  group('MythBusterScreen', () {
    testWidgets('renders initial question card and response buttons', (tester) async {
      await tester.pumpWidget(createSubject(shuffle: false));
      await tester.pumpAndSettle();

      // Top bar title and HIDE
      expect(find.text('Myth Buster Quiz'), findsOneWidget);
      expect(find.byType(HideButton), findsOneWidget);

      // Question 1 progress
      expect(find.text('QUESTION 1 OF 5'), findsOneWidget);

      // Question badge
      expect(find.text('?'), findsOneWidget);

      // Question 1 statement (hair washing myth)
      expect(
        find.textContaining('You should never wash your hair during periods'),
        findsOneWidget,
      );

      // Sub-prompt
      expect(
        find.text('Is this cultural saying true or false?'),
        findsOneWidget,
      );

      // Buttons
      expect(find.text("It's a MYTH"), findsOneWidget);
      expect(find.text("It's a FACT"), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('answering correctly displays positive feedback and explanation', (tester) async {
      await tester.pumpWidget(createSubject(shuffle: false));
      await tester.pumpAndSettle();

      // Question 1 is a myth -> tap "It's a MYTH"
      await tester.tap(find.text("It's a MYTH"));
      await tester.pumpAndSettle();

      // Feedback is visible
      expect(find.textContaining('Correct!'), findsOneWidget);
      expect(
        find.textContaining('Washing your hair is safe and keeps you clean'),
        findsOneWidget,
      );

      // Next button visible, answer buttons hidden
      expect(find.text('Next'), findsOneWidget);
      expect(find.text("It's a MYTH"), findsNothing);
      expect(find.text("It's a FACT"), findsNothing);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('answering incorrectly displays constructive feedback', (tester) async {
      await tester.pumpWidget(createSubject(shuffle: false));
      await tester.pumpAndSettle();

      // Question 1 is a myth -> tap "It's a FACT" (incorrect)
      await tester.tap(find.text("It's a FACT"));
      await tester.pumpAndSettle();

      // Feedback indicates not quite
      expect(find.textContaining('Not quite'), findsOneWidget);
      expect(
        find.textContaining('Washing your hair is safe and keeps you clean'),
        findsOneWidget,
      );
      expect(find.text('Next'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('full 5-question run displays results and persists best score', (tester) async {
      await tester.pumpWidget(createSubject(shuffle: false));
      await tester.pumpAndSettle();

      // Q1: Myth -> Tap Myth (Correct)
      await tester.tap(find.text("It's a MYTH"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Q2: Exercise -> Myth -> Tap Myth (Correct)
      expect(find.text('QUESTION 2 OF 5'), findsOneWidget);
      await tester.tap(find.text("It's a MYTH"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Q3: Iron -> Fact -> Tap Fact (Correct)
      expect(find.text('QUESTION 3 OF 5'), findsOneWidget);
      await tester.tap(find.text("It's a FACT"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Q4: Impure -> Myth -> Tap Myth (Correct)
      expect(find.text('QUESTION 4 OF 5'), findsOneWidget);
      await tester.tap(find.text("It's a MYTH"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Q5: Irregular -> Fact -> Tap Fact (Correct)
      expect(find.text('QUESTION 5 OF 5'), findsOneWidget);
      await tester.tap(find.text("It's a FACT"));
      await tester.pumpAndSettle();

      // Button on last question is "See Results"
      expect(find.text('See Results'), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(find.text('See Results'));
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Results view
      expect(find.text('Quiz Complete!'), findsOneWidget);
      expect(find.text('You got 5 of 5'), findsOneWidget);
      expect(find.textContaining('Personal Best: 5 / 5'), findsOneWidget);
      expect(find.text('Play again'), findsOneWidget);
      expect(find.text('Back to hub'), findsOneWidget);

      // Verify Hive settings box has best score saved
      final box = Hive.box<dynamic>('settings');
      expect(box.get('quiz_best_score'), 5);

      // Tap Play again to restart
      await tester.tap(find.text('Play again'));
      await tester.pumpAndSettle();

      expect(find.text('QUESTION 1 OF 5'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('tapping HIDE button clears stack to MainScreen and locks session', (tester) async {
      expect(sessionState.unlocked, isTrue);

      await tester.pumpWidget(
        ChangeNotifierProvider<SessionState>.value(
          value: sessionState,
          child: const MaterialApp(
            home: Scaffold(body: Text('PreviousScreen')),
          ),
        ),
      );

      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.push(MaterialPageRoute(
        builder: (_) => const MythBusterScreen(),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MythBusterScreen), findsOneWidget);
      expect(find.byType(HideButton), findsOneWidget);

      // Tap HIDE button
      await tester.tap(find.byType(HideButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Swapped to MainScreen
      expect(find.byType(MainScreen), findsOneWidget);
      expect(find.byType(MythBusterScreen), findsNothing);

      // Session is locked
      expect(sessionState.unlocked, isFalse);

      // Stack is cleared
      expect(nav.canPop(), isFalse);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
