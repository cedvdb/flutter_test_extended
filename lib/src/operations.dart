import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart' as f;
import 'package:flutter_test/flutter_test.dart';

export 'package:flutter_test/flutter_test.dart' hide group, testWidgets;

typedef TestCallback = Future<void> Function(WidgetTester tester);

final _setupCallbacks = <Function, Function>{};
Function? _currentBody;

void group(String description, VoidCallback body) {
  f.group(description, () {
    _currentBody = body;
    body();
    _currentBody = null;
  });
}

void setUpWidgets(TestCallback callback) {
  if (_currentBody == null) {
    throw 'not in a group';
  }
  _setupCallbacks[_currentBody!] = callback;
}

void testWidgets(
  String description,
  TestCallback callback, {
  bool? skip,
  f.Timeout? timeout,
  bool semanticsEnabled = true,
  TestVariant<Object?> variant = const DefaultTestVariant(),
  dynamic tags,
}) {
  final setupWidgets = _setupCallbacks[_currentBody];

  f.testWidgets(
    description,
    (tester) async {
      await setupWidgets?.call(tester);
      await callback(tester);
    },
    skip: skip,
    timeout: timeout,
    semanticsEnabled: semanticsEnabled,
    variant: variant,
    tags: tags,
  );
}