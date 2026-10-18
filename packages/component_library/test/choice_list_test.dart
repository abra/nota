import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('ChoiceList', () {
    testWidgets('shows section headings and checks the selected value', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(
        _wrap(
          ChoiceList<String?>(
            sections: const [
              ChoiceSection(choices: [Choice(value: null, label: 'Automatic')]),
              ChoiceSection(
                title: 'Recent',
                choices: [Choice(value: 'ru', label: 'Russian')],
              ),
              ChoiceSection(title: 'Empty', choices: []),
              ChoiceSection(
                title: 'All',
                choices: [
                  Choice(value: 'de', label: 'German'),
                  Choice(value: 'en', label: 'English'),
                ],
              ),
            ],
            selected: 'ru',
            onSelected: (value) => picked = value,
          ),
        ),
      );

      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Empty'), findsNothing, reason: 'empty sections hide');
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(
        tester.getCenter(find.byIcon(Icons.check_rounded)).dy,
        tester.getCenter(find.text('Russian')).dy,
      );

      await tester.tap(find.text('German'));
      expect(picked, 'de');
      await tester.tap(find.text('Automatic'));
      expect(picked, isNull);
    });

    testWidgets('marks the selected row for accessibility', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(
          ChoiceList<int>(
            sections: const [
              ChoiceSection(
                choices: [
                  Choice(value: 1, label: 'One'),
                  Choice(value: 2, label: 'Two'),
                ],
              ),
            ],
            selected: 2,
            onSelected: (_) {},
          ),
        ),
      );

      expect(
        tester.getSemantics(find.text('Two')),
        matchesSemantics(
          label: 'Two',
          isSelected: true,
          hasSelectedState: true,
          isInMutuallyExclusiveGroup: true,
          isButton: true,
          isFocusable: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('builds rows lazily and scrolls within maxHeight', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ChoiceList<int>(
            maxHeight: 300,
            sections: [
              ChoiceSection(
                choices: [
                  for (var i = 0; i < 200; i++)
                    Choice(value: i, label: 'Language $i'),
                ],
              ),
            ],
            selected: 0,
            onSelected: (_) {},
          ),
        ),
      );

      expect(tester.getSize(find.byType(ChoiceList<int>)).height, 300);
      expect(find.text('Language 0'), findsOneWidget);
      expect(find.text('Language 199'), findsNothing);

      await tester.scrollUntilVisible(find.text('Language 120'), 400);
      expect(find.text('Language 120'), findsOneWidget);
    });

    testWidgets('is only as tall as a short list', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ChoiceList<int>(
            sections: const [
              ChoiceSection(choices: [Choice(value: 1, label: 'Only')]),
            ],
            selected: 1,
            onSelected: (_) {},
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(ChoiceList<int>)).height,
        lessThan(100),
      );
    });
  });
}
