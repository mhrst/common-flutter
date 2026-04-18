import 'package:flutter/widgets.dart';

extension CharacterLengthAt on String {
  int characterLengthAt(int index) {
    assert(index > 0 && index <= length);
    return substring(index).characters.first.length;
  }

  int characterLengthBefore(int index) {
    assert(index > 0 && index <= length);
    return substring(0, index).characters.last.length;
  }
}

extension RangeSafeSubstring on String {
  String rangeSafeSubstring(int start, int end) {
    if (start < 0) start = 0;
    if (end > length) end = length;
    if (start >= end) return '';
    return substring(start, end);
  }
}

extension RemoveRanges on String {
  String removeRanges(Iterable<TextRange> ranges) {
    if (ranges.isEmpty) return this;
    final buffer = StringBuffer();
    var start = 0;
    for (final range in ranges) {
      buffer.write(substring(start, range.start));
      start = range.end;
    }
    buffer.write(substring(start));
    return buffer.toString();
  }
}
