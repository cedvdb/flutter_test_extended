import 'package:flutter/material.dart';

class Screenshotter extends StatelessWidget {
  final Widget child;

  const Screenshotter(
    this.child, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: const ValueKey('screenshotter'),
      child: child,
    );
  }
}
