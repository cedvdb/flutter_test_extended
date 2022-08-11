

# Test operations

```dart

void main() {
  group('', () {

    setUpWidgets((tester) async {
      await tester.test(const MyApp());
    });

    testWidgets('Counter increments smoke test', (WidgetTester tester) async {
      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // Tap the '+' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);

      // will block test if uncommented, handy for debugging
      // await tester.printScreenshot();
    });
  });
}
```

# Integration test:

```dart
/// allows to run the "integration" test file in memory.
/// It ensures that IntegrationTestWidgetsFlutterBinding is initialized
/// only when running when running flutter drive, if flutter test is called,
/// this has no impact.
/// The use case is to run the same integration test in memory as the real
/// integration test by swapping the datasources to in memory data sources
/// (as opposed to network / device calls), for the test to run faster.
/// Usually the data source would be swapped with an env variable or arg.
ensureInitialized();
```

# Tester operations

- printScreenshot()
- tapType<T>()
- tapKey('value-key-value');
- enterTextOnKey('value-key-value')
- scrollListViewUntilWidgetVisible
- ...

