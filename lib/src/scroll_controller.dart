import 'package:flutter/widgets.dart';

extension ScrollControllerExtensions on ScrollController {
  /// Calls [scrollToPosition] with the bottom position.
  Future<void> scrollToBottom() => scrollToPosition(position.maxScrollExtent);

  /// Repeatedly scrolls the scrollController until it reaches the target position
  /// or 5 seconds have passed.
  Future<void> scrollToPosition(double value) async {
    if (!hasClients) return;

    final startTime = DateTime.now();

    // Clamp the target within scroll extents to avoid overscroll
    final double target = value.clamp(0.0, position.maxScrollExtent).toDouble();

    if ((position.pixels - target).abs() <= 0.5) {
      return;
    }

    while ((position.pixels - target).abs() > 0.5) {
      if (DateTime.now().difference(startTime) > const Duration(seconds: 5)) {
        break;
      }

      await animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      await Future.delayed(const Duration(milliseconds: 200));
    }

    if ((position.pixels - target).abs() > 0.5) {
      jumpTo(target);
    }
  }

  /// Calls [scrollToPosition] with the top position.
  Future<void> scrollToTop() => scrollToPosition(0.0);
}
