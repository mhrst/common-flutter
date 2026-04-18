import 'package:flutter/widgets.dart';

/// Mixin on [State] that skips calling [setState] if the widget is
/// not mounted. Prevents errors in cases where the widget is disposed before
/// the state is updated. This is a common pattern in async code that calls
/// [setState] after an async operation completes.
mixin SafeSetState<T extends StatefulWidget> on State<T> {
  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      fn();
    } else {
      super.setState(fn);
    }
  }
}
