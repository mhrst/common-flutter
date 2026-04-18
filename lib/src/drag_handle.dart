import 'package:flutter/material.dart';

const kDragHandleHeight = 24.0;
const kDragHandleThickness = 6.0;
const kDragHandleWidth = 40.0;

class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: kDragHandleHeight,
      child: Center(
        child: Container(
          height: kDragHandleThickness,
          width: kDragHandleWidth,
          decoration: ShapeDecoration(
            color: theme.brightness == Brightness.dark
                ? Colors.white12
                : Colors.black12,
            shape: const StadiumBorder(),
          ),
        ),
      ),
    );
  }
}
