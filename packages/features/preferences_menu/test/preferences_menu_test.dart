import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preferences_menu/preferences_menu.dart';
import 'package:preferences_service/preferences_service.dart';
import 'package:shared/shared.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const _testLanguages = <SupportedLanguage>[
  (code: 'en', name: 'English'),
  (code: 'ru', name: 'Русский'),
];

Future<PreferencesService> _createService() => PreferencesService.create(
  supportedCodes: _testLanguages.map((l) => l.code).toList(),
);

Widget _buildMenu(PreferencesService service) {
  return MaterialApp(
    localizationsDelegates: const [
      PreferencesLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('ru')],
    home: Scaffold(
      body: PreferencesMenu(
        service: service,
        supportedLanguages: _testLanguages,
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('PreferencesMenu', () {
    testWidgets('shows "Preferences" title', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildMenu(service));

      expect(find.text('Preferences'), findsOneWidget);
    });

    testWidgets('shows Theme, Notes view, List density, Language labels', (
      tester,
    ) async {
      final service = await _createService();
      await tester.pumpWidget(_buildMenu(service));

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Notes view'), findsOneWidget);
      expect(find.text('List density'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets(
      'shows three SegmentedButtons (Theme, Notes view, List density)',
      (tester) async {
        final service = await _createService();
        await tester.pumpWidget(_buildMenu(service));

        expect(
          find.byWidgetPredicate((w) => w is SegmentedButton),
          findsNWidgets(3),
        );
      },
    );

    testWidgets('shows close button on main page', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildMenu(service));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('updates theme preference on segment tap', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildMenu(service));

      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pump();

      expect(service.current.themeMode, ThemeMode.dark);
    });

    testWidgets('updates noteViewMode to list on segment tap', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildMenu(service));

      await tester.tap(find.byIcon(Icons.view_agenda_outlined));
      await tester.pump();

      expect(service.current.noteViewMode, NoteViewMode.list);
    });

    testWidgets('shows current language name on main page', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildMenu(service));

      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('navigates to language page on language tap', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildMenu(service));

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Русский'), findsOneWidget);
    });

    testWidgets('updates locale to RU via language page', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildMenu(service));

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Русский'));
      await tester.pumpAndSettle();

      expect(service.current.locale.languageCode, 'ru');
    });

    testWidgets('back arrow returns to main page', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildMenu(service));

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Preferences'), findsOneWidget);
    });

    testWidgets('rebuilds when cubit emits new locale', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildMenu(service));

      final cubit = tester
          .element(find.byType(AnimatedSize))
          .read<PreferencesCubit>();
      await cubit.update((p) => p.copyWith(locale: const Locale('ru')));
      await tester.pump();

      expect(find.text('Русский'), findsOneWidget);
    });
  });
}
