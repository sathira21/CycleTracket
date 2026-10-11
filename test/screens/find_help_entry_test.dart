import 'package:cycle_care/screens/find_help_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('marked Find Help actions work from the location tab', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const FindHelpScreen()),
                  );
                },
                child: const Text('Location'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Location'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Find Help\nNearby'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Filters'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('DISTANCE FROM YOU'), findsWidgets);
    expect(tester.takeException(), isNull);

    tester.state<NavigatorState>(find.byType(Navigator).last).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Use My Location'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Allow location access'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text("Don't allow"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Search area or place...'), findsWidgets);
    expect(tester.takeException(), isNull);

    tester.state<NavigatorState>(find.byType(Navigator).last).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Visit readiness checklist'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Supply Readiness'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).last).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.text('Places you keep'));
    await tester.tap(find.text('Places you keep'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Saved places'), findsWidgets);
    expect(find.text('Location'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
