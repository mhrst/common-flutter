import 'package:flutter/material.dart';

extension CurrentLanguageTag on Localizations {
  String languageTagOf(BuildContext context, {String fallback = 'en'}) {
    final locale = Localizations.maybeLocaleOf(context);
    final languageTag = locale?.toLanguageTag().replaceAll('-', '_');
    if (languageTag == null || languageTag.isEmpty) {
      return fallback;
    }
    return languageTag.toLowerCase();
  }
}
