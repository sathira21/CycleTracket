import 'package:find_help/main.dart';
import 'package:find_help/real_map.dart';
import 'package:find_help/screens/details_screen.dart';
import 'package:find_help/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('marked nearby features open and act without errors', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const FindHelpApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);

    expect(find.text('Find Help\nNearby'), findsOneWidget);
    expect(find.text('Search Osu Sala, pharmacy, MOH, or a town'), findsOneWidget);
    expect(find.textContaining('List view'), findsOneWidget);
    expect(find.text('Interactive map'), findsOneWidget);
    expect(find.text('Use My Location'), findsOneWidget);
    expect(find.text('Visit readiness checklist'), findsOneWidget);

    await _tapChip(tester, 'Open now');
    await _tapChip(tester, 'Open now');
    await _tapChip(tester, 'Free');
    await _tapChip(tester, 'Free');
    await _tapChip(tester, 'Pads');
    await _tapChip(tester, 'Pads');
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextField).first, 'Kottawa');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Kottawa'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);

    await _scrollTap(tester, find.textContaining('Under'));
    expect(find.textContaining('place'), findsWidgets);
    expect(find.text('Call'), findsWidgets);
    expect(find.text('View details'), findsWidgets);
    expect(tester.takeException(), isNull);

    await _openAndBack(tester, find.text('Filters'), find.text('DISTANCE FROM YOU'));
    await _tapChip(tester, 'Help');
    expect(find.text('How to find pharmacies and clinics'), findsWidgets);
    expect(tester.takeException(), isNull);
    await _back(tester);
    await _tapChip(tester, 'Search area');
    expect(find.text('Search area or place...'), findsWidgets);
    expect(tester.takeException(), isNull);
    await _back(tester);

    await _scrollTap(tester, find.text('Visit readiness checklist'));
    expect(find.text('Add item'), findsWidgets);
    expect(tester.takeException(), isNull);
    await _back(tester);

    await _scrollTap(tester, find.text('Supplies'));
    expect(find.text('Add item'), findsWidgets);
    await _back(tester);

    await _scrollTap(tester, find.text('Saved'));
    expect(find.text('Saved places'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Map'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await _scrollTap(tester, find.text('Notes'));
    expect(find.text('Add note'), findsWidgets);
    expect(tester.takeException(), isNull);
    await _back(tester);

    await _scrollTap(tester, find.text('Reminders'));
    expect(find.text('Add reminder'), findsWidgets);
    expect(tester.takeException(), isNull);
    await _back(tester);

    await _scrollTap(tester, find.text('Tap to see the full history'));
    expect(find.text('Visit history'), findsWidgets);
    expect(tester.takeException(), isNull);
    await _back(tester);

    await tester.tap(find.text('Use My Location'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Allow location access'), findsOneWidget);
    await tester.tap(find.text("Don't allow"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Search area or place...'), findsWidgets);
    expect(tester.takeException(), isNull);
    await _back(tester);

    await _scrollTap(tester, find.text('Call'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    await _scrollTap(tester, find.text('View details'));
    expect(find.byType(DetailsScreen), findsOneWidget);
    expect(find.text('FACILITY PROFILE'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final detailsCall = find.descendant(of: find.byType(DetailsScreen), matching: find.text('Call'));
    final detailsList = find.descendant(
      of: find.byType(DetailsScreen),
      matching: find.byWidgetPredicate((widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down),
    );
    final detailsPosition = tester.state<ScrollableState>(detailsList).position;
    for (var attempt = 0; attempt < 12 && detailsCall.hitTestable().evaluate().isEmpty; attempt++) {
      detailsPosition.jumpTo((detailsPosition.pixels + 320).clamp(0, detailsPosition.maxScrollExtent));
      await tester.pump();
    }
    await tester.tap(detailsCall.hitTestable().first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    await _back(tester);

    final homeList = find.descendant(
      of: find.byType(HomeScreen),
      matching: find.byWidgetPredicate((widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down),
    );
    tester.state<ScrollableState>(homeList).position.jumpTo(0);
    await tester.pump();
    await tester.tap(find.text('Interactive map'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AnimatedFinderMap), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.textContaining('List view'));
    await tester.pump();
    final listPosition = tester.state<ScrollableState>(homeList).position;
    for (var attempt = 0; attempt < 16 && find.text('Call').evaluate().isEmpty; attempt++) {
      listPosition.jumpTo((listPosition.pixels + 280).clamp(0, listPosition.maxScrollExtent));
      await tester.pump();
    }
    expect(find.text('Call'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _tapChip(WidgetTester tester, String label) async {
  final chips = find.byKey(const Key('home-chips'));
  final homeList = find.descendant(
    of: find.byType(HomeScreen),
    matching: find.byWidgetPredicate((widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down),
  );
  final vertical = tester.state<ScrollableState>(homeList).position;
  vertical.jumpTo(0);
  await tester.pump();
  for (var attempt = 0; attempt < 12 && chips.hitTestable().evaluate().isEmpty; attempt++) {
    vertical.jumpTo((vertical.pixels + 160).clamp(0, vertical.maxScrollExtent));
    await tester.pump();
  }

  final chip = find.descendant(of: chips, matching: find.text(label));
  final row = find.descendant(of: chips, matching: find.byType(Scrollable));
  final horizontal = tester.state<ScrollableState>(row).position;
  horizontal.jumpTo(0);
  await tester.pump();
  for (var attempt = 0; attempt < 12 && chip.hitTestable().evaluate().isEmpty; attempt++) {
    if (horizontal.pixels >= horizontal.maxScrollExtent - 1) break;
    horizontal.jumpTo((horizontal.pixels + 72).clamp(0, horizontal.maxScrollExtent));
    await tester.pump();
  }
  await tester.tap(chip.hitTestable().first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _openAndBack(WidgetTester tester, Finder opener, Finder landed) async {
  await _scrollTap(tester, opener);
  expect(landed, findsWidgets);
  expect(tester.takeException(), isNull);
  await _back(tester);
}

Future<void> _scrollTap(WidgetTester tester, Finder target) async {
  final list = find.descendant(
    of: find.byType(HomeScreen),
    matching: find.byWidgetPredicate(
      (widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down,
    ),
  );
  final position = tester.state<ScrollableState>(list).position;
  for (var attempt = 0; attempt < 24; attempt++) {
    if (target.evaluate().isNotEmpty && target.hitTestable().evaluate().isNotEmpty) break;
    final next = position.pixels + 280;
    if (next > position.maxScrollExtent) {
      position.jumpTo(0);
    } else {
      position.jumpTo(next);
    }
    await tester.pump();
  }
  await tester.tap(target.hitTestable().first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _back(WidgetTester tester) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
  navigator.pop();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  expect(tester.takeException(), isNull);
}
