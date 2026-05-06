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

class OverflowMenu extends StatelessWidget {
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
  Widget build(BuildContext context) => ListTileTheme(
    dense: true,
    minVerticalPadding: 0,
    horizontalTitleGap: 0,
    child: MenuAnchor(
      consumeOutsideTap: true,
      useRootOverlay: true,
      controller: controller,
      onClose: onClose,
      menuChildren: [
        _OverflowMenuItems(controller: controller, itemsBuilder: itemsBuilder),
      ],
      builder:
          builder ??
          (context, controller, _) => IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: controller.isOpen
                ? controller.close
                : () {
                    onOpen?.call();
                    controller.open();
                  },
          ),
    ),
  );
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
              onTap: () {
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
