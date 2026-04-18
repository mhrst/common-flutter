import 'package:flutter/widgets.dart';

class HackScrollController extends ScrollController {
  // Causes early return from EditableText._showCaretOnScreen, preventing focus
  // gain from making the CustomScrollView jump to the top.
  @override
  bool get hasClients => false;
}
