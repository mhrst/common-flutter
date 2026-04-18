import 'package:flutter/material.dart';

const kColorBlack = Color(0xFF000000);
const kColorCancelGrey = Color(0xFF607D8B);
const kColorConfirmGreen = Color(0xFF00AA33);
const kColorErrorRed = Color(0xFFFF0033);
const kColorWarnOrange = Color(0xFFFFAA00);
const kColorWhite = Color(0xFFFFFFFF);
const kColorDarkModeOutline = Color(0x1AFFFFFF);
const kColorLightModeOutine = Color(0x1A000000);

/// Because [Color.computeLuminance] is expensive, we cache the results.
final _kContrastColorMap = <Color, Color>{};

extension ColorExtensions on Color {
  /// Returns a constrasting [Color], either black or white
  Color get contrast => _kContrastColorMap.putIfAbsent(
    this,
    () => computeLuminance() > .33 ? kColorBlack : kColorWhite,
  );

  String get hexValue => toARGB32().toRadixString(16);

  /// Returns a [Color] from a hex string. The string can be 6 or 7
  /// characters long and optionally prefixed with a '#'.
  static Color fromHex(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.blue;
    }
  }
}
