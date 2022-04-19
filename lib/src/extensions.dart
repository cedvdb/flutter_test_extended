import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:ui' as ui;

import 'screenshotter.dart';

extension ExtendedTestWidget on WidgetTester {
  Future<void> test(
    Widget widget, [
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
  ]) async {
    await pumpWidget(
      Screenshotter(
        widget,
      ),
      duration,
      phase,
    );
    await pump(const Duration(milliseconds: 100));
  }

  Future<void> flushAsyncTask() async {
    await runAsync(() async {});
  }

  /// returns a base64 screenshot of the screen, useful for making a
  /// diagnostic for unit test failures.
  Future<String> takeScreenshot() async {
    final renderObj = renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('screenshotter')));
    ui.Image image = await renderObj.toImage(pixelRatio: 3);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    String bs64 = base64Encode(pngBytes);
    return bs64;
  }

  /// prints base64 screenshot of unit test to console (will block the test)
  Future<void> printScreenshot() async {
    final screenshot = await takeScreenshot();
    // ignore: avoid_print
    print(screenshot);
  }

  /// convenience method to tap a certain type
  Future<void> tapType<T extends Widget>() async {
    final found = find.byType(T);
    expect(found, findsOneWidget);
    await ensureVisible(found);
    await tap(find.byType(T));
  }

  /// convenience method to tap a ValueKey
  Future<void> tapKey(String key) async {
    final found = find.byKey(ValueKey(key));
    expect(found, findsOneWidget);
    await ensureVisible(found);
    await tap(found);
  }

  /// convenience method to get a widget instance by Type
  T widgetByType<T extends Widget>() {
    final found = find.byType(T);
    expect(found, findsOneWidget);
    return widget<T>(found);
  }

  /// convenience method to enter text on ValueKey
  Future<void> enterTextOnKey({
    required String text,
    required String key,
  }) async {
    final found = find.byKey(ValueKey(key));
    await ensureVisible(found);
    await enterText(found, text);
    await pumpAndSettle();
  }

  /// convenience method to enter text on ValueKey
  Future<void> enterTextOnType<T>({
    required String text,
    required String key,
  }) async {
    final found = find.byType(T);
    await ensureVisible(found);
    await enterText(found, text);
    await pumpAndSettle();
  }

  /// convenience method that ensures a ValueKey is visible
  Future<void> ensureKeyVisible(String key) async {
    final found = find.byKey(ValueKey(key));
    expect(found, findsOneWidget);
    await ensureVisible(found);
  }

  /// Scrolls until [finder] finds a single [Widget].
  ///
  /// This helper is only required because [WidgetTester.ensureVisible] does not yet work for items that are scrolled
  /// out of view in a [ListView]. See https://github.com/flutter/flutter/issues/17668. Once that issue is resolved,
  /// we should be able to remove this altogether.
  ///
  /// On top of that, this would ideally be an extension method against [WidgetTester], but at the time of writing,
  /// extension methods are not yet available in the stable channel.
  Future<void> scrollListViewUntilWidgetVisible(
    Finder finder, {
    Finder? listView,
    Offset scrollBy = const Offset(0, -50),
    int maxScrolls = 300,
  }) async {
    listView ??= find.byType(ListView);
    final gesture = await startGesture(getCenter(listView));

    Widget? foundWidget;

    for (var i = 0; i < maxScrolls; ++i) {
      await gesture.moveBy(scrollBy);
      await pump();
      final widgets = widgetList(finder);

      if (widgets.length == 1) {
        foundWidget = widgets.first;
        break;
      }
    }

    await gesture.cancel();

    expect(foundWidget, isNotNull);

    // Just because we found the widget, doesn't mean it's visible. It could be off-stage. But now we can at least use the standard
    // ensureVisible method to bring it on-screen.
    await ensureVisible(finder);
    // Attempting to bring the widget on-screen may result in it being scrolled too far up in a list, in which case it will bounce back
    // once the gesture above completes. We need to pump for long enough for the bounce-back animation to complete.
    await pump(const Duration(seconds: 1));
  }
}
