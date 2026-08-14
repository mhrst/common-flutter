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

  testWidgets('uses compact horizontal spacing for menu rows', (tester) async {
    final controller = MenuController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OverflowMenu(
            controller: controller,
            itemsBuilder: (context) => [
              OverflowMenuListTile(
                leading: const Icon(Icons.star, key: ValueKey('leading')),
                title: const Text('Compact row', key: ValueKey('title')),
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

    final tileRect = tester.getRect(find.byType(ListTile));
    final leadingRect = tester.getRect(find.byKey(const ValueKey('leading')));
    final titleRect = tester.getRect(find.byKey(const ValueKey('title')));
    expect(leadingRect.left - tileRect.left, 8);
    expect(titleRect.left - tileRect.left, 32);
    expect(tileRect.right - titleRect.right, 8);
  });
}
