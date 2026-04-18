import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Policy", with the "Terms of Service" and "Privacy Policy" text being
/// tappable.
Widget richTextWithOnTap({
  required BuildContext context,
  required String input,
  required Map<int, Function()> onTapMap,
  TextAlign textAlign = TextAlign.center,
  TextStyle? textStyle,
}) {
  List<InlineSpan> textSpans = [];
  int start = 0;

  RegExp regExp = RegExp(r'<(\d+):(.*?)>');

  final color = Theme.of(context).colorScheme.secondary;

  regExp.allMatches(input).forEach((match) {
    String text = input.substring(start, match.start);
    int id = int.parse(match.group(1)!);
    String linkText = match.group(2)!;

    if (text.isNotEmpty) {
      textSpans.add(TextSpan(text: text));
    }

    Function() onTap = onTapMap[id]!;
    textSpans.add(
      TextSpan(
        text: linkText,
        style: TextStyle(color: color, decoration: TextDecoration.underline),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            onTap();
          },
      ),
    );

    // Keep track of the index of the end of the link so we can
    // add the remaining text after the link.
    start = match.end;
  });

  // Add any remaining text after the last link
  if (start < input.length) {
    textSpans.add(TextSpan(text: input.substring(start)));
  }

  return RichText(
    textAlign: textAlign,
    text: TextSpan(children: textSpans, style: textStyle),
  );
}

TextPainter textPainterForStyle(BuildContext context, TextStyle? style) =>
    TextPainter(
      text: TextSpan(text: ' ', style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: 12.0);
