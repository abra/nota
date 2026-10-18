import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/app/config/supported_locales.dart';
import 'package:nota/app/dependency_container.dart';
import 'package:nota/app/platform/app_settings_opener.dart';
import 'package:note_details/note_details.dart';
import 'package:note_list/note_list.dart';
import 'package:preferences_menu/preferences_menu.dart';
import 'package:shared/shared.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

abstract final class AppRoutes {
  static const notes = '/notes';
  static const newNote = '/notes/new';

  /// A new note whose editor opens in dictation straight away.
  static const newVoiceNote = '/notes/new?dictate=1';

  static String noteEditor(String id) => '/notes/$id';
}

/// Keeps the screen on during hands-free dictation.
Future<void> _keepScreenAwake(bool enabled) =>
    WakelockPlus.toggle(enable: enabled);

/// Lets the user grant a denied microphone or speech permission.
Future<void> _openAppSettings() => AppSettingsOpener.open();

GoRouter buildRouter({required DependenciesContainer dependencies}) {
  dependencies.logger.debug('buildRouter: GoRouter created');

  return GoRouter(
    debugLogDiagnostics: dependencies.config.isDev,
    initialLocation: AppRoutes.notes,
    routes: [
      GoRoute(
        path: AppRoutes.notes,
        builder: (context, state) => NoteListScreen(
          noteRepository: dependencies.noteRepository,
          preferencesService: dependencies.preferencesService,
          imageFiles: dependencies.imageFiles,
          onAddPressed: () => context.push<Note?>(AppRoutes.newNote),
          onAddLongPressed: () => context.push<Note?>(AppRoutes.newVoiceNote),
          onNotePressed: (note) => context.push<Note?>(
            AppRoutes.noteEditor(note.id),
          ),
          onSettingsPressed: (ctx) => showModalBottomSheet<void>(
            context: ctx,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => PreferencesMenu(
              service: dependencies.preferencesService,
              supportedLanguages: SupportedLocales.languages,
              appVersion: dependencies.packageInfo.version,
              loadDictationLanguages: () =>
                  loadDictationLanguages(dependencies.speechService),
            ),
          ),
        ),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => NoteDetailsScreen(
              noteRepository: dependencies.noteRepository,
              imageFiles: dependencies.imageFiles,
              speechService: dependencies.speechService,
              preferencesService: dependencies.preferencesService,
              keepScreenAwake: _keepScreenAwake,
              openAppSettings: _openAppSettings,
              startDictation: state.uri.queryParameters['dictate'] == '1',
            ),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => NoteDetailsScreen(
              noteRepository: dependencies.noteRepository,
              imageFiles: dependencies.imageFiles,
              speechService: dependencies.speechService,
              preferencesService: dependencies.preferencesService,
              keepScreenAwake: _keepScreenAwake,
              openAppSettings: _openAppSettings,
              noteId: state.pathParameters['id'],
            ),
          ),
        ],
      ),
    ],
  );
}
