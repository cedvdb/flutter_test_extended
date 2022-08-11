import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart' as f;
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

export 'package:flutter_test/flutter_test.dart' hide group, testWidgets;
import 'package:integration_test/integration_test.dart' as integration;

bool get _isTestingRunningInMemory =>
    !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

/// allows to run the same test file for integration and unit tests.
/// It ensures that IntegrationTestWidgetsFlutterBinding is initialized
/// only when running a non unit test (so when running flutter drive).
/// The use case is to run the same integration test in memory as the real
/// integration test by swapping the datasources to in memory data sources
/// (as opposed to network / device calls), for the test to run faster.
void ensureInitialized() {
  if (!_isTestingRunningInMemory) {
    integration.IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  }
}

typedef TestCallback = Future<void> Function(WidgetTester tester);

final _setupCallbacks = <Function, TestCallback>{};
final _tearDownCallbacks = <Function, TestCallback>{};

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

void tearDownWidgets(TestCallback callback) {
  if (_currentBody == null) {
    throw 'not in a group';
  }
  _tearDownCallbacks[_currentBody!] = callback;
}

void testWidgets(
  String description,
  TestCallback callback, {
  bool runSetUpWidgets = true,
  bool? skip,
  f.Timeout? timeout,
  bool semanticsEnabled = true,
  TestVariant<Object?> variant = const DefaultTestVariant(),
  dynamic tags,
  HttpMockStrategy fakeNetworkSuccess = HttpMockStrategy.inMemoryTestOnly,
}) {
  final setupWidgets = _setupCallbacks[_currentBody];
  final tearDownWidgets = _tearDownCallbacks[_currentBody];
  final shouldFakeNetork = fakeNetworkSuccess == HttpMockStrategy.always ||
      (fakeNetworkSuccess == HttpMockStrategy.inMemoryTestOnly &&
          _isTestingRunningInMemory);
  f.testWidgets(
    description,
    (tester) async {
      if (shouldFakeNetork) {
        await mockNetworkImagesFor(
          () => _testWidgetsBody(
            tester: tester,
            runSetUpWidgets: runSetUpWidgets,
            callback: callback,
            setupWidgets: setupWidgets,
            tearDownWidgets: tearDownWidgets,
          ),
        );
      } else {
        await _testWidgetsBody(
          tester: tester,
          runSetUpWidgets: runSetUpWidgets,
          callback: callback,
          setupWidgets: setupWidgets,
          tearDownWidgets: tearDownWidgets,
        );
      }
    },
    skip: skip,
    timeout: timeout,
    semanticsEnabled: semanticsEnabled,
    variant: variant,
    tags: tags,
  );
}

Future<void> _testWidgetsBody({
  required WidgetTester tester,
  required bool runSetUpWidgets,
  required TestCallback callback,
  required TestCallback? setupWidgets,
  required TestCallback? tearDownWidgets,
}) async {
  if (runSetUpWidgets) {
    await setupWidgets?.call(tester);
  }
  await callback(tester);
  if (runSetUpWidgets) {
    await tearDownWidgets?.call(tester);
  }
}

enum HttpMockStrategy { never, always, inMemoryTestOnly }
