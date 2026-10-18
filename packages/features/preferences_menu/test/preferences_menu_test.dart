import 'dart:async';

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

Widget _buildMenu(
  PreferencesService service, {
  Future<List<DictationLanguage>> Function()? loadDictationLanguages,
}) {
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
        loadDictationLanguages: loadDictationLanguages,
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
      'shows four SegmentedButtons (Theme, Notes view, List density, Pause)',
      (tester) async {
        final service = await _createService();
        await tester.pumpWidget(_buildMenu(service));

        expect(
          find.byWidgetPredicate((w) => w is SegmentedButton),
          findsNWidgets(4),
        );
      },
    );

    testWidgets('shows the dictation rows', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildMenu(service));

      expect(find.text('Pause between phrases'), findsOneWidget);
      expect(find.text('Voice commands'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('selecting a pause length updates the preferences', (
      tester,
    ) async {
      final service = await _createService();
      await tester.pumpWidget(_buildMenu(service));

      await tester.tap(find.text('Long'));
      await tester.pumpAndSettle();

      expect(service.current.dictationPause, DictationPause.long);
    });

    testWidgets('the voice commands switch updates the preferences', (
      tester,
    ) async {
      final service = await _createService();
      await tester.pumpWidget(_buildMenu(service));
      expect(service.current.voiceCommands, isTrue);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(service.current.voiceCommands, isFalse);
    });

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

  group('Dictation language', () {
    const ru = DictationLanguage(tag: 'ru-RU', name: 'Russian (Russia)');
    const enUs = DictationLanguage(tag: 'en-US', name: 'English (US)');
    const de = DictationLanguage(tag: 'de-DE', name: 'German (Germany)');

    Future<PreferencesService> pumpMenu(
      WidgetTester tester,
      Future<List<DictationLanguage>> Function() load,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final service = await _createService();
      await tester.pumpWidget(
        _buildMenu(service, loadDictationLanguages: load),
      );
      return service;
    }

    testWidgets('has no row without a way to list the languages', (
      tester,
    ) async {
      final service = await _createService();
      await tester.pumpWidget(_buildMenu(service));

      expect(find.text('Dictation language'), findsNothing);
    });

    testWidgets('follows the app language until one is picked', (
      tester,
    ) async {
      await pumpMenu(tester, () async => [ru, enUs]);

      expect(find.text('Dictation language'), findsOneWidget);
      expect(find.text('Same as app'), findsOneWidget);
    });

    testWidgets('lists the recogniser languages once, after loading', (
      tester,
    ) async {
      final languages = Completer<List<DictationLanguage>>();
      var loads = 0;
      await pumpMenu(tester, () {
        loads++;
        return languages.future;
      });

      await tester.tap(find.text('Same as app'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      languages.complete([ru, enUs, de]);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('All languages'), findsOneWidget);
      expect(find.text('Recent'), findsNothing, reason: 'nothing picked yet');
      expect(
        tester.getTopLeft(find.text('English (US)')).dy,
        lessThan(tester.getTopLeft(find.text('German (Germany)')).dy),
      );
      expect(
        tester.getTopLeft(find.text('German (Germany)')).dy,
        lessThan(tester.getTopLeft(find.text('Russian (Russia)')).dy),
      );
      expect(loads, 1);
    });

    testWidgets('picking a language stores it and shows it on the main page', (
      tester,
    ) async {
      final service = await pumpMenu(tester, () async => [ru, enUs]);

      await tester.tap(find.text('Same as app'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Russian (Russia)'));
      await tester.pumpAndSettle();

      expect(service.current.dictationLanguage, ru);
      expect(service.current.recentDictationLanguages, ['ru-RU']);
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Russian (Russia)'), findsOneWidget);
    });

    testWidgets('shows recent languages first and can follow the app again', (
      tester,
    ) async {
      final service = await pumpMenu(tester, () async => [ru, enUs, de]);
      await tester
          .element(find.byType(AnimatedSize))
          .read<PreferencesCubit>()
          .update((p) => p.withDictationLanguage(de).withDictationLanguage(ru));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Russian (Russia)'));
      await tester.pumpAndSettle();

      expect(find.text('Recent'), findsOneWidget);
      final recentTop = tester.getTopLeft(find.text('Recent')).dy;
      final allTop = tester.getTopLeft(find.text('All languages')).dy;
      for (final name in ['Russian (Russia)', 'German (Germany)']) {
        final top = tester.getTopLeft(find.text(name)).dy;
        expect(top, inExclusiveRange(recentTop, allTop), reason: name);
      }
      expect(
        tester.getTopLeft(find.text('English (US)')).dy,
        greaterThan(allTop),
      );

      await tester.tap(find.text('Same as app'));
      await tester.pumpAndSettle();

      expect(service.current.dictationLanguage, isNull);
      expect(find.text('Same as app'), findsOneWidget);
    });

    testWidgets('explains an empty list and still offers the app language', (
      tester,
    ) async {
      await pumpMenu(tester, () async => const []);

      await tester.tap(find.text('Same as app'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('did not list its languages'),
        findsOneWidget,
      );
      expect(find.text('Same as app'), findsOneWidget);
    });
  });
}
