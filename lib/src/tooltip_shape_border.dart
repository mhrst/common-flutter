import 'package:flutter/widgets.dart';

class TooltipShapeBorder extends ShapeBorder {
  final double arrowHeight;
  final double arrowWidth;
  final double arrowArc;
  final double radius;
  final Alignment arrowAlignment;
  final bool isBelow;
  final bool isAbove;

  const TooltipShapeBorder({
    this.radius = 8.0,
    this.arrowHeight = 10.0,
    this.arrowWidth = 20.0,
    this.arrowArc = 0.2,
    required this.arrowAlignment,
    required this.isAbove,
    required this.isBelow,
  }) : assert(arrowArc <= 1.0 && arrowArc >= 0.0);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(right: arrowHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // Down arrows (for tooltips above the target)
    if (isAbove) {
      if (arrowAlignment == Alignment.bottomLeft) {
        return _downArrowLeftPath(rect, textDirection: textDirection);
      }
      if (arrowAlignment == Alignment.bottomRight) {
        return _downArrowRightPath(rect, textDirection: textDirection);
      }
      if (arrowAlignment == Alignment.bottomCenter) {
        return _downArrowCenterPath(rect, textDirection: textDirection);
      }
    }

    // Up arrows (for tooltips below the target)
    if (isBelow) {
      if (arrowAlignment == Alignment.topLeft) {
        return _upArrowLeftPath(rect, textDirection: textDirection);
      }
      if (arrowAlignment == Alignment.topRight) {
        return _upArrowRightPath(rect, textDirection: textDirection);
      }
      if (arrowAlignment == Alignment.topCenter) {
        return _upArrowCenterPath(rect, textDirection: textDirection);
      }
    }

    // Left arrows
    if (arrowAlignment == Alignment.centerLeft) {
      return _leftArrowCenterPath(rect, textDirection: textDirection);
    }
    if (arrowAlignment == Alignment.bottomLeft) {
      return _leftArrowBottomPath(rect, textDirection: textDirection);
    }
    if (arrowAlignment == Alignment.topLeft) {
      return _leftArrowTopPath(rect, textDirection: textDirection);
    }

    // Right arrows
    if (arrowAlignment == Alignment.centerRight) {
      return _rightArrowCenterPath(rect, textDirection: textDirection);
    }
    if (arrowAlignment == Alignment.bottomRight) {
      return _rightArrowBottomPath(rect, textDirection: textDirection);
    }
    if (arrowAlignment == Alignment.topRight) {
      return _rightArrowTopPath(rect, textDirection: textDirection);
    }

    // Default to center down arrow if no other conditions match
    return _downArrowCenterPath(rect, textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;

  // https://stackoverflow.com/questions/58352828/flutter-design-instagram-like-balloons-tooltip-widget
  Path _downArrowCenterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topLeft, rect.bottomRight);
    double x = arrowWidth, y = arrowHeight, r = 1 - arrowArc;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..moveTo(rect.bottomCenter.dx + x / 2, rect.bottomCenter.dy)
      ..relativeLineTo(-x / 2 * r, y * r)
      ..relativeQuadraticBezierTo(
          -x / 2 * (1 - r), y * (1 - r), -x * (1 - r), 0)
      ..relativeLineTo(-x / 2 * r, -y * r);
  }

  Path _downArrowLeftPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topLeft, rect.bottomRight);
    double x = arrowWidth, y = arrowHeight, r = 1 - arrowArc;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..moveTo(rect.bottomLeft.dx + x / 2, rect.bottomLeft.dy)
      ..relativeLineTo(x / 2 * r, y * r)
      ..relativeQuadraticBezierTo(x / 2 * (1 - r), y * (1 - r), x * (1 - r), 0)
      ..relativeLineTo(x / 2 * r, -y * r);
  }

  Path _downArrowRightPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topLeft, rect.bottomRight);
    double x = arrowWidth, y = arrowHeight, r = 1 - arrowArc;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..moveTo(rect.bottomRight.dx - x - x / 2, rect.bottomRight.dy)
      ..relativeLineTo(x / 2 * r, y * r)
      ..relativeQuadraticBezierTo(x / 2 * (1 - r), y * (1 - r), x * (1 - r), 0)
      ..relativeLineTo(x / 2 * r, -y * r);
  }

  Path _leftArrowBottomPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topRight, rect.bottomLeft);
    double x = arrowHeight, y = arrowWidth, r = 1 - arrowArc;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..moveTo(rect.centerLeft.dx, rect.bottomLeft.dy - y / 2)
      ..relativeLineTo(-x * r, -y / 2 * r)
      ..relativeQuadraticBezierTo(
          -x * (1 - r), -y / 2 * (1 - r), 0, -y * (1 - r))
      ..relativeLineTo(x * r, -y / 2 * r);
  }

  Path _leftArrowCenterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topRight, rect.bottomLeft);
    double x = arrowHeight, y = arrowWidth, r = 1 - arrowArc;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..moveTo(rect.centerLeft.dx, rect.center.dy)
      ..relativeLineTo(-x * r, -y / 2 * r)
      ..relativeQuadraticBezierTo(
          -x * (1 - r), -y / 2 * (1 - r), 0, -y * (1 - r))
      ..relativeLineTo(x * r, -y / 2 * r);
  }

  Path _leftArrowTopPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topRight, rect.bottomLeft);
    double x = arrowHeight, y = arrowWidth, r = 1 - arrowArc;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..moveTo(rect.centerLeft.dx, rect.topLeft.dy + y / 2)
      ..relativeLineTo(-x * r, y / 2 * r)
      ..relativeQuadraticBezierTo(-x * (1 - r), y / 2 * (1 - r), 0, y * (1 - r))
      ..relativeLineTo(x * r, y / 2 * r);
  }

  // @override
  // Path _downArrowLeftPath(Rect rect, {TextDirection? textDirection}) {
  //   rect = Rect.fromPoints(
  //       rect.topLeft, rect.bottomRight - Offset(0, arrowHeight));
  //   double x = arrowWidth, y = arrowHeight, r = 1 - arrowArc;
  //   return Path()
  //     ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
  //     ..moveTo(rect.bottomCenter.dx + x / 2, rect.bottomCenter.dy)
  //     ..relativeLineTo(-x / 2 * r, y * r)
  //     ..relativeQuadraticBezierTo(
  //         -x / 2 * (1 - r), y * (1 - r), -x * (1 - r), 0)
  //     ..relativeLineTo(-x / 2 * r, -y * r);
  // }

  Path _rightArrowBottomPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topLeft, rect.bottomRight);
    double x = arrowHeight, y = arrowWidth, r = 1 - arrowArc;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..moveTo(rect.centerRight.dx, rect.bottomRight.dy - y / 2)
      ..relativeLineTo(x * r, -y / 2 * r)
      ..relativeQuadraticBezierTo(
          x * (1 - r), -y / 2 * (1 - r), 0, -y * (1 - r))
      ..relativeLineTo(-x * r, -y / 2 * r);
  }

  Path _rightArrowCenterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topLeft, rect.bottomRight);
    double x = arrowHeight, y = arrowWidth, r = 1 - arrowArc;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..moveTo(rect.centerRight.dx, rect.center.dy)
      ..relativeLineTo(x * r, -y / 2 * r)
      ..relativeQuadraticBezierTo(
          x * (1 - r), -y / 2 * (1 - r), 0, -y * (1 - r))
      ..relativeLineTo(-x * r, -y / 2 * r);
  }

  Path _rightArrowTopPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topLeft, rect.bottomRight);
    double x = arrowHeight, y = arrowWidth, r = 1 - arrowArc;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..moveTo(rect.centerRight.dx, rect.topRight.dy + y / 2)
      ..relativeLineTo(x * r, y / 2 * r)
      ..relativeQuadraticBezierTo(x * (1 - r), y / 2 * (1 - r), 0, y * (1 - r))
      ..relativeLineTo(-x * r, y / 2 * r);
  }

  Path _upArrowCenterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topLeft, rect.bottomRight);
    double x = arrowHeight, y = arrowWidth; //, r = 1 - arrowArc;

    final arrowCenter = rect.center.dx;

    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..moveTo(arrowCenter - y / 2, rect.top)
      ..lineTo(arrowCenter, rect.top - x)
      ..lineTo(arrowCenter + y / 2, rect.top);
  }

  Path _upArrowLeftPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topLeft, rect.bottomRight);
    double x = arrowHeight, y = arrowWidth, r = 1 - arrowArc;

    final arrowCenter = rect.left + y + r * 2;

    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..moveTo(arrowCenter - y / 2, rect.top)
      ..lineTo(arrowCenter, rect.top - x)
      ..lineTo(arrowCenter + y / 2, rect.top);
  }

  Path _upArrowRightPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topLeft, rect.bottomRight);
    double x = arrowHeight, y = arrowWidth, r = 1 - arrowArc;

    final arrowCenter = rect.right - y - r * 2;

    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..moveTo(arrowCenter - y / 2, rect.top)
      ..lineTo(arrowCenter, rect.top - x)
      ..lineTo(arrowCenter + y / 2, rect.top);
  }
}
