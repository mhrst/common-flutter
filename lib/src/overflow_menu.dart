import 'dart:math' as math;

import 'package:flutter/material.dart';

class OverflowMenuItem {
  final Widget child;
  final VoidCallback? onTap;

  const OverflowMenuItem({required this.child, this.onTap});
}

class OverflowMenuListTile extends OverflowMenuItem {
  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final Widget? subtitle;

  const OverflowMenuListTile({
    required this.title,
    super.onTap,
    this.leading,
    this.trailing,
    this.subtitle,
  }) : super(child: title);
}

typedef OverflowMenuItemsBuilder =
    List<OverflowMenuItem> Function(BuildContext context);

/// Displays overflow actions without placing them beneath system UI.
///
/// [MenuAnchor] already scrolls a menu whose contents exceed its constraints.
/// However, its height constraint does not include system insets, and an
/// ancestor [SafeArea] may remove those insets from the ambient [MediaQuery].
/// Restoring the view's system metrics and reserving the obscured area gives
/// the built-in scroll container the usable screen height instead.
class OverflowMenu extends StatelessWidget {
  static const _screenMargin = 8.0;

  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  final MenuController controller;
  final OverflowMenuItemsBuilder itemsBuilder;
  final MenuAnchorChildBuilder? builder;

  const OverflowMenu({
    super.key,
    required this.itemsBuilder,
    required this.controller,
    this.builder,
    this.onOpen,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Root overlays cover the whole view, so they need the original system
    // insets even when the menu trigger lives below a SafeArea.
    final ambientMediaQuery = MediaQuery.of(context);
    final viewMediaQuery = MediaQueryData.fromView(View.of(context));
    final overlayMediaQuery = ambientMediaQuery.copyWith(
      padding: viewMediaQuery.padding,
      viewPadding: viewMediaQuery.viewPadding,
      viewInsets: viewMediaQuery.viewInsets,
      systemGestureInsets: viewMediaQuery.systemGestureInsets,
    );

    // Constrain the menu to the unobscured part of the view. MenuAnchor uses
    // this height for its own SingleChildScrollView when every item cannot fit.
    final safePadding = viewMediaQuery.padding;
    final viewInsets = viewMediaQuery.viewInsets;
    final reservedPadding = EdgeInsets.fromLTRB(
      math.max(safePadding.left, viewInsets.left) + _screenMargin,
      math.max(safePadding.top, viewInsets.top) + _screenMargin,
      math.max(safePadding.right, viewInsets.right) + _screenMargin,
      math.max(safePadding.bottom, viewInsets.bottom) + _screenMargin,
    );

    return MediaQuery(
      data: overlayMediaQuery,
      child: ListTileTheme(
        dense: true,
        minVerticalPadding: 0,
        horizontalTitleGap: 0,
        child: MenuAnchor(
          consumeOutsideTap: true,
          useRootOverlay: true,
          reservedPadding: reservedPadding,
          controller: controller,
          onClose: onClose,
          menuChildren: [
            _OverflowMenuItems(
              controller: controller,
              itemsBuilder: itemsBuilder,
            ),
          ],
          builder:
              builder ??
              (context, controller, _) => IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: controller.isOpen
                    ? controller.close
                    : () {
                        onOpen?.call();
                        controller.open();
                      },
              ),
        ),
      ),
    );
  }
}

class _OverflowMenuItems extends StatelessWidget {
  final MenuController controller;
  final OverflowMenuItemsBuilder itemsBuilder;

  const _OverflowMenuItems({
    required this.controller,
    required this.itemsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in itemsBuilder(context))
          switch (item) {
            OverflowMenuListTile() => ListTile(
              title: item.title,
              leading: item.leading,
              trailing: item.trailing,
              subtitle: item.subtitle,
              // Put the callback on the row itself so the whole option has
              // button semantics and the menu closes before the action runs.
              onTap: item.onTap == null
                  ? null
                  : () {
                      controller.close();
                      item.onTap?.call();
                    },
            ),
            _ when item.onTap != null => InkWell(
              onTap: item.onTap,
              child: item.child,
            ),
            _ => item.child,
          },
      ],
    );
  }
}
