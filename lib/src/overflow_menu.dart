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
/// [MenuAnchor] normally scrolls contents that exceed its constraints, but its
/// scrollbar also treats landscape system insets as padding inside the popup.
/// An ancestor [SafeArea] can additionally remove those insets from the
/// ambient [MediaQuery]. This widget reserves the obscured area for placement
/// and owns the menu scroll view so its scrollbar stays against the panel edge.
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

    // Use the unobscured part of the view for both anchor placement and the
    // menu's local scroll constraint.
    final safePadding = viewMediaQuery.padding;
    final viewInsets = viewMediaQuery.viewInsets;
    final reservedPadding = EdgeInsets.fromLTRB(
      math.max(safePadding.left, viewInsets.left) + _screenMargin,
      math.max(safePadding.top, viewInsets.top) + _screenMargin,
      math.max(safePadding.right, viewInsets.right) + _screenMargin,
      math.max(safePadding.bottom, viewInsets.bottom) + _screenMargin,
    );
    final maximumMenuHeight = math.max(
      0.0,
      viewMediaQuery.size.height - reservedPadding.vertical,
    );

    return MediaQuery(
      data: overlayMediaQuery,
      child: ListTileTheme.merge(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        minVerticalPadding: 0,
        horizontalTitleGap: 0,
        child: MenuAnchor(
          consumeOutsideTap: true,
          useRootOverlay: true,
          reservedPadding: reservedPadding,
          // OverflowMenu owns scrolling so it can remove window padding from
          // the local scrollbar without changing root-overlay positioning.
          style: const MenuStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
          ),
          controller: controller,
          onClose: onClose,
          menuChildren: [
            _OverflowMenuItems(
              controller: controller,
              itemsBuilder: itemsBuilder,
              maximumHeight: maximumMenuHeight,
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

class _OverflowMenuItems extends StatefulWidget {
  final MenuController controller;
  final OverflowMenuItemsBuilder itemsBuilder;
  final double maximumHeight;

  const _OverflowMenuItems({
    required this.controller,
    required this.itemsBuilder,
    required this.maximumHeight,
  });

  @override
  State<_OverflowMenuItems> createState() => _OverflowMenuItemsState();
}

class _OverflowMenuItemsState extends State<_OverflowMenuItems> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.maximumHeight),
      // Flutter's scrollbar treats the view's landscape safe area as padding
      // inside this local popup. Remove it only from the menu contents; the
      // outer MenuAnchor still uses the full metrics for safe positioning.
      child: MediaQuery.removePadding(
        context: context,
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        child: Scrollbar(
          key: const ValueKey('overflow_menu_scrollbar'),
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final item in widget.itemsBuilder(context))
                    switch (item) {
                      OverflowMenuListTile() => ListTile(
                        title: item.title,
                        leading: item.leading,
                        trailing: item.trailing,
                        subtitle: item.subtitle,
                        // Put the callback on the row itself so the whole
                        // option has button semantics and closes before the
                        // action runs.
                        onTap: item.onTap == null
                            ? null
                            : () {
                                widget.controller.close();
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
