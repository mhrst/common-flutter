import 'package:common_flutter/common_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps every option reachable above the system navigation area', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 320);
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    addTearDown(tester.view.reset);

    final controller = MenuController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          // SafeArea removes its padding from descendants. The menu still
          // needs that original inset because it is drawn in the root overlay.
          body: SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: OverflowMenu(
                controller: controller,
                itemsBuilder: (context) => [
                  for (var index = 0; index < 12; index++)
                    OverflowMenuListTile(
                      title: Text(
                        'Option $index',
                        key: ValueKey('option_$index'),
                      ),
                      onTap: () {},
                    ),
                ],
                builder: (context, controller, _) => TextButton(
                  onPressed: controller.open,
                  child: const Text('Open menu'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open menu'));
    await tester.pumpAndSettle();

    final menuScrollbar = find.byKey(const ValueKey('overflow_menu_scrollbar'));
    final dynamic scrollbarState = tester.state(
      find.descendant(
        of: menuScrollbar,
        matching: find.byWidgetPredicate((widget) => widget is RawScrollbar),
      ),
    );
    expect(scrollbarState.scrollbarPainter.padding, EdgeInsets.zero);

    expect(
      find.byKey(const ValueKey('option_0')).hitTestable(),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('option_11')).hitTestable(), findsNothing);

    // OverflowMenu's local scroll container receives the safe, finite height.
    await tester.drag(
      find.byKey(const ValueKey('option_0')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();

    final lastOption = find.byKey(const ValueKey('option_11')).hitTestable();
    expect(lastOption, findsOneWidget);
    expect(tester.getRect(lastOption).bottom, lessThanOrEqualTo(264));
  });

  testWidgets('puts the action handler on the complete menu row', (
    tester,
  ) async {
    var wasTapped = false;
    final controller = MenuController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OverflowMenu(
            controller: controller,
            itemsBuilder: (context) => [
              OverflowMenuListTile(
                title: const Text('Run action'),
                onTap: () => wasTapped = true,
              ),
            ],
            builder: (context, controller, _) => TextButton(
              onPressed: controller.open,
              child: const Text('Open menu'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open menu'));
    await tester.pumpAndSettle();

    final row = tester.widget<ListTile>(
      find.ancestor(
        of: find.text('Run action'),
        matching: find.byType(ListTile),
      ),
    );
    expect(row.onTap, isNotNull);

    await tester.tap(find.text('Run action'));
    await tester.pumpAndSettle();

    expect(wasTapped, isTrue);
    expect(controller.isOpen, isFalse);
  });

  testWidgets('does not apply a landscape system inset inside the menu', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 320);
    tester.view.padding = const FakeViewPadding(right: 80);
    tester.view.viewPadding = const FakeViewPadding(right: 80);
    addTearDown(tester.view.reset);

    final controller = MenuController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: OverflowMenu(
                controller: controller,
                itemsBuilder: (context) => [
                  OverflowMenuItem(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 240,
                        maxWidth: 320,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Menu header'),
                      ),
                    ),
                  ),
                  for (var index = 0; index < 12; index++)
                    OverflowMenuListTile(
                      leading: const Icon(Icons.star),
                      title: Text('Option $index'),
                      onTap: () {},
                    ),
                ],
                builder: (context, controller, _) => TextButton(
                  onPressed: controller.open,
                  child: const Text('Open menu'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open menu'));
    await tester.pumpAndSettle();

    final menuScrollbar = find.byKey(const ValueKey('overflow_menu_scrollbar'));
    final dynamic scrollbarState = tester.state(
      find.descendant(
        of: menuScrollbar,
        matching: find.byWidgetPredicate((widget) => widget is RawScrollbar),
      ),
    );
    expect(scrollbarState.scrollbarPainter.padding, EdgeInsets.zero);

    final menuContainer = find
        .ancestor(of: menuScrollbar, matching: find.byType(Material))
        .first;
    expect(tester.getRect(menuContainer).right, lessThanOrEqualTo(720));

    final scrollView = tester.widget<SingleChildScrollView>(
      find.descendant(
        of: menuScrollbar,
        matching: find.byType(SingleChildScrollView),
      ),
    );
    expect(scrollView.controller!.position.maxScrollExtent, greaterThan(0));

    final anchorScrollView = tester
        .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView))
        .singleWhere((view) => view.controller != scrollView.controller);
    expect(anchorScrollView.controller!.position.maxScrollExtent, 0);
  });

  testWidgets('matches the compact layout of custom menu rows', (tester) async {
    final controller = MenuController();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: Scaffold(
          body: OverflowMenu(
            controller: controller,
            itemsBuilder: (context) => [
              const OverflowMenuItem(
                child: ListTile(
                  key: ValueKey('custom_tile'),
                  contentPadding: EdgeInsets.only(left: 18),
                  leading: Icon(Icons.star, key: ValueKey('custom_leading')),
                  title: Text('Custom row', key: ValueKey('custom_title')),
                ),
              ),
              OverflowMenuListTile(
                leading: const Icon(Icons.star, key: ValueKey('menu_leading')),
                title: const Text('Menu row', key: ValueKey('menu_title')),
                onTap: () {},
              ),
            ],
            builder: (context, controller, _) => TextButton(
              onPressed: controller.open,
              child: const Text('Open menu'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open menu'));
    await tester.pumpAndSettle();

    final menuTileFinder = find.ancestor(
      of: find.byKey(const ValueKey('menu_title')),
      matching: find.byType(ListTile),
    );
    final menuTile = tester.widget<ListTile>(menuTileFinder);
    expect(menuTile.contentPadding, isNull);
    expect(menuTile.dense, isNull);
    expect(menuTile.horizontalTitleGap, isNull);
    expect(menuTile.minLeadingWidth, isNull);
    expect(menuTile.minVerticalPadding, isNull);

    final menuTileRect = tester.getRect(menuTileFinder);
    final menuLeadingRect = tester.getRect(
      find.byKey(const ValueKey('menu_leading')),
    );
    final menuTitle = find.byKey(const ValueKey('menu_title'));
    final menuTitleRect = tester.getRect(menuTitle);
    expect(menuLeadingRect.left - menuTileRect.left, 18);
    expect(menuTileRect.right - menuTitleRect.right, 18);

    final customTileRect = tester.getRect(
      find.byKey(const ValueKey('custom_tile')),
    );
    final customLeadingRect = tester.getRect(
      find.byKey(const ValueKey('custom_leading')),
    );
    final customTitle = find.byKey(const ValueKey('custom_title'));
    final customTitleRect = tester.getRect(customTitle);
    expect(menuLeadingRect.left, customLeadingRect.left);
    expect(menuTileRect.height, customTileRect.height);
    expect(
      menuTitleRect.left - menuLeadingRect.right,
      customTitleRect.left - customLeadingRect.right,
    );

    final menuText = tester.widget<RichText>(
      find.descendant(of: menuTitle, matching: find.byType(RichText)),
    );
    final customText = tester.widget<RichText>(
      find.descendant(of: customTitle, matching: find.byType(RichText)),
    );
    expect(menuText.text.style, customText.text.style);

    final tileTheme = ListTileTheme.of(tester.element(menuTitle));
    expect(tileTheme.dense, isTrue);
    expect(
      tileTheme.contentPadding,
      const EdgeInsets.symmetric(horizontal: 18),
    );
    expect(tileTheme.horizontalTitleGap, 0);
    expect(tileTheme.minVerticalPadding, 0);
    expect(tileTheme.minLeadingWidth, isNull);
  });
}
