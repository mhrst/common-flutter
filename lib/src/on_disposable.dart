import 'package:flutter/widgets.dart';

class OnDisposable extends StatefulWidget {
  final void Function() onDispose;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  const OnDisposable({
    super.key,
    required this.child,
    required this.onDispose,
  });

  @override
  OnDisposableState createState() => OnDisposableState();
}

class OnDisposableState extends State<OnDisposable> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    super.dispose();
    widget.onDispose();
  }
}
