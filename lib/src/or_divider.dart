import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry labelPadding;
  final double lineThickness;
  final double lineGap;
  final Color? lineColor;
  final TextStyle? textStyle;

  const OrDivider({
    super.key,
    this.text = 'or',
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.lineThickness = 1.0,
    this.lineGap = 0.0,
    this.lineColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveLineColor =
        lineColor ?? Theme.of(context).colorScheme.outlineVariant;
    final TextStyle effectiveTextStyle =
        textStyle ??
        Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return Row(
      children: [
        Expanded(
          child: _Line(
            color: effectiveLineColor,
            thickness: lineThickness,
            height: lineThickness + 8.0 + lineGap,
          ),
        ),
        Padding(
          padding: labelPadding,
          child: Text(text, style: effectiveTextStyle),
        ),
        Expanded(
          child: _Line(
            color: effectiveLineColor,
            thickness: lineThickness,
            height: lineThickness + 8.0 + lineGap,
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  final double thickness;
  final double height;
  final Color color;

  const _Line({
    required this.thickness,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Divider(thickness: thickness, height: height, color: color),
    );
  }
}
