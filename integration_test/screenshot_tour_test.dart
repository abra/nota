// Walks through every screen with seeded demo notes and takes screenshots.
// Used to review the UI on a real device/simulator and to refresh README
// images.
//
// Two ways to capture:
//  * `flutter drive --driver=test_driver/integration_test.dart
//     --target=integration_test/screenshot_tour_test.dart -d <device>`
//    saves PNGs through the host driver (see test_driver/).
//  * `flutter test integration_test/screenshot_tour_test.dart -d <device>`
//    with `tool/screenshot_watcher.sh` running on the host: the test drops a
//    `<name>.req` marker in its temp dir, the watcher grabs the simulator
//    screen with `simctl io` and answers with `<name>.ack`.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:monitoring/monitoring.dart';
import 'package:nota/app/composition.dart';
import 'package:nota/app/config/application_config.dart';
import 'package:nota/app/dependency_container.dart';
import 'package:nota/app/root_context.dart';
import 'package:shared/shared.dart';
import 'package:speech_service/speech_service.dart';
import 'package:speech_service/testing.dart';

String _delta(List<Map<String, Object?>> ops) => jsonEncode({'ops': ops});

Map<String, Object?> _line(String text, {bool bold = false}) => {
  'insert': text,
  if (bold) 'attributes': {'bold': true},
};

Map<String, Object?> _break({String? list}) => {
  'insert': '\n',
  if (list != null) 'attributes': {'list': list},
};

/// Takes a screenshot through the driver when one is attached, otherwise via
/// the file handshake described at the top of this file.
Future<void> _snap(
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  // Let the raster thread present the settled frame before capturing.
  await Future<void>.delayed(const Duration(milliseconds: 350));
  if (_driverAttached) {
    await _snap(binding, name);
    return;
  }
  final dir = _handshakeDir..createSync(recursive: true);
  final ack = File('${dir.path}/$name.ack');
  // A stale ack from an earlier run would let us continue before the watcher
  // has captured the frame.
  if (ack.existsSync()) ack.deleteSync();
  File('${dir.path}/$name.req').writeAsStringSync('');
  final deadline = DateTime.now().add(const Duration(seconds: 8));
  while (!ack.existsSync()) {
    if (DateTime.now().isAfter(deadline)) {
      debugPrint('screenshot "$name": no watcher answered, skipping');
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  ack.deleteSync();
}

/// Plays a short grocery dialogue into the scripted speech service so the
/// dictation panel has something to show. Simulators have no recogniser.
Future<void> _playDictationDemo(ScriptedSpeechService speech) async {
  if (speech.startCalls.length > 1) return;
  Future<void> beat([int ms = 300]) =>
      Future<void>.delayed(Duration(milliseconds: ms));
  await beat();
  speech.partial('Fresh');
  await beat(250);
  speech.partial('Fresh basil');
  await beat(400);
  speech.finalText('Fresh basil');
  await beat(600);
  speech.partial('Olive');
  await beat(250);
  speech.partial('Olive oil');
  speech.level(0.6);
}

// `flutter drive` sets this define; `flutter test` does not.
const _driverAttached = bool.fromEnvironment(
  'NOTA_DRIVER',
  defaultValue: false,
);

final _handshakeDir = Directory('${Directory.systemTemp.path}/nota_shots');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('screenshot tour', (tester) async {
    // Drop requests/acks left behind by an interrupted run.
    if (_handshakeDir.existsSync()) _handshakeDir.deleteSync(recursive: true);

    final logger = createAppLogger();
    final result = await composeDependencies(
      config: const ApplicationConfig(),
      logger: logger,
      errorReporter: const NoopErrorReporter(),
    );
    final base = result.dependencies;
    final deps = DependenciesContainer(
      logger: base.logger,
      config: base.config,
      errorReporter: base.errorReporter,
      packageInfo: base.packageInfo,
      preferencesService: base.preferencesService,
      noteRepository: base.noteRepository,
      imageFiles: base.imageFiles,
      speechService: ScriptedSpeechService(
        locales: const [SpeechLocale(id: 'en_US', name: 'English (US)')],
        onStart: _playDictationDemo,
      ),
    );
    final repo = deps.noteRepository;
    final prefs = deps.preferencesService;

    // Fresh start: English, light, grid, no notes.
    await prefs.update(
      (p) => p.copyWith(
        locale: const Locale('en'),
        themeMode: ThemeMode.light,
        noteViewMode: NoteViewMode.grid,
        noteListDensity: NoteListDensity.threeLines,
      ),
    );
    for (final n in await repo.getNotes()) {
      await repo.deleteNote(n.id);
    }

    final now = DateTime.now();
    Future<void> seed({
      required String id,
      String? title,
      required String content,
      NoteColor color = NoteColor.none,
      bool isPinned = false,
      Duration age = Duration.zero,
    }) => repo.restoreNote(
      Note(
        id: id,
        title: title,
        content: content,
        color: color,
        isPinned: isPinned,
        createdAt: now.subtract(age),
        updatedAt: now.subtract(age),
      ),
    );

    await seed(
      id: 'groceries',
      title: 'Groceries',
      color: NoteColor.yellow,
      isPinned: true,
      age: const Duration(hours: 2),
      content: _delta([
        _line('Oat milk'),
        _break(list: 'checked'),
        _line('Sourdough bread'),
        _break(list: 'checked'),
        _line('Avocados'),
        _break(list: 'unchecked'),
        _line('Coffee beans'),
        _break(list: 'unchecked'),
        _line('Lemons'),
        _break(list: 'unchecked'),
      ]),
    );
    await seed(
      id: 'lisbon',
      title: 'Lisbon weekend',
      color: NoteColor.blue,
      isPinned: true,
      age: const Duration(days: 1, hours: 3),
      content: _delta([
        _line('Tram 28 at sunrise'),
        _break(list: 'bullet'),
        _line('Pastéis de Belém'),
        _break(list: 'bullet'),
        _line('LX Factory on Sunday'),
        _break(list: 'bullet'),
        _line('Book Time Out Market table'),
        _break(list: 'bullet'),
      ]),
    );
    await seed(
      id: 'meeting',
      title: 'Design sync',
      age: const Duration(days: 2, hours: 5),
      content: _delta([
        _line(
          'Agreed to simplify the onboarding to two steps. Open question: '
          'keep the tour or replace it with inline hints? Follow up with '
          'Mara on Thursday.',
        ),
        _break(),
      ]),
    );
    await seed(
      id: 'quick',
      color: NoteColor.mint,
      age: const Duration(hours: 5),
      content: _delta([
        _line('Call the dentist tomorrow at 10:00'),
        _break(),
      ]),
    );
    await seed(
      id: 'books',
      title: 'Reading list',
      color: NoteColor.rose,
      age: const Duration(days: 4),
      content: _delta([
        _line('Piranesi'),
        _break(list: 'ordered'),
        _line('The Dispossessed'),
        _break(list: 'ordered'),
        _line('Tomorrow, and Tomorrow, and Tomorrow'),
        _break(list: 'ordered'),
      ]),
    );
    await seed(
      id: 'ideas',
      title: 'App ideas',
      age: const Duration(days: 12),
      content: _delta([
        _line('Pocket garden planner', bold: true),
        _break(),
        _line('Reminders based on sunlight hours and soil moisture sensors.'),
        _break(),
      ]),
    );
    await seed(
      id: 'quote',
      color: NoteColor.sand,
      age: const Duration(days: 40),
      content: _delta([
        _line('“Simplicity is the ultimate sophistication.”'),
        _break(),
      ]),
    );

    await tester.pumpWidget(
      RootContext(
        compositionResult: CompositionResult(
          dependencies: deps,
          millisecondsSpent: result.millisecondsSpent,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _snap(binding, '01_list_grid_light');

    await prefs.update((p) => p.copyWith(themeMode: ThemeMode.dark));
    await tester.pumpAndSettle();
    await _snap(binding, '02_list_grid_dark');

    await prefs.update(
      (p) => p.copyWith(
        themeMode: ThemeMode.light,
        noteViewMode: NoteViewMode.list,
      ),
    );
    await tester.pumpAndSettle();
    await _snap(binding, '03_list_list_light');

    await prefs.update((p) => p.copyWith(noteViewMode: NoteViewMode.grid));
    await tester.pumpAndSettle();

    // Selection mode.
    await tester.longPress(find.text('Design sync'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reading list'));
    await tester.pumpAndSettle();
    await _snap(binding, '04_selection');
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Editor with checklist + colour.
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();
    await _snap(binding, '05_editor_checklist');
    await tester.tap(find.byTooltip('Formatting'));
    await tester.pumpAndSettle();
    await _snap(binding, '06_editor_formatting');
    await tester.tap(find.byTooltip('Note color'));
    await tester.pumpAndSettle();
    await _snap(binding, '07_editor_colors');
    // Dictation: the scripted service commits "Fresh basil" as a new item
    // and leaves "Olive oil" in progress.
    await tester.tap(find.byTooltip('Dictate'));
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();
    await _snap(binding, '08_editor_dictation');
    await tester.tap(find.byTooltip('Dictate'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Editor, dark theme, uncoloured note.
    await prefs.update((p) => p.copyWith(themeMode: ThemeMode.dark));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Design sync'));
    await tester.pumpAndSettle();
    await _snap(binding, '09_editor_dark');
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await prefs.update((p) => p.copyWith(themeMode: ThemeMode.light));
    await tester.pumpAndSettle();

    // New note.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await _snap(binding, '10_editor_new');
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Preferences sheet.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await _snap(binding, '11_preferences');
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await _snap(binding, '12_preferences_language');
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Search with no results.
    await tester.enterText(find.byType(TextField), 'zebra');
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    await _snap(binding, '13_search_empty');
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    // Delete with undo toast, then empty state.
    await tester.longPress(find.text('Design sync'));
    await tester.pumpAndSettle();
    for (final t in [
      'Groceries',
      'Lisbon weekend',
      'Reading list',
      'App ideas',
    ]) {
      await tester.tap(find.text(t));
      await tester.pump();
    }
    await tester.tap(find.text('Call the dentist tomorrow at 10:00'));
    await tester.pump();
    await tester.tap(find.text('“Simplicity is the ultimate sophistication.”'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump(const Duration(milliseconds: 600));
    await _snap(binding, '14_deleted_undo');
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    await _snap(binding, '15_restored');
  });
}
