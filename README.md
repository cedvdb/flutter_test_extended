

# Test operations

```dart

void main() {
  group('', () {

    setUpWidgets((tester) async {
      await tester.pumpWidget(const MyApp());
    });

    testWidgets('Counter increments smoke test', (WidgetTester tester) async {
      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // Tap the '+' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });
  });
}
```

# Tester operations



