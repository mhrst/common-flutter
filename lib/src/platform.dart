import 'package:flutter/foundation.dart';

bool get kIsAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

bool get kIsCupertino =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

bool get kIsIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

bool get kIsMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

extension TargetPlatformExtension on TargetPlatform {
  bool get isCupertino =>
      this == TargetPlatform.iOS || this == TargetPlatform.macOS;
}
