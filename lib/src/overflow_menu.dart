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

class OverflowMenu extends StatelessWidget {
  final VoidCallback? onOpen;
  final MenuController controller;
  final List<OverflowMenuItem> items;
  final MenuAnchorChildBuilder? builder;

  const OverflowMenu({
    super.key,
    required this.items,
    required this.controller,
    this.builder,
    this.onOpen,
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
      menuChildren: [
        for (final item in items)
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
