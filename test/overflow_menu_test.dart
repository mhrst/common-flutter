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

    expect(
      find.byKey(const ValueKey('option_0')).hitTestable(),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('option_11')).hitTestable(), findsNothing);

    // MenuAnchor supplies the scroll container once the menu receives the
    // safe, finite height from OverflowMenu.
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
}
