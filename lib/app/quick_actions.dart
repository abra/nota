// Home-screen quick actions (3D Touch / long-press on the app icon).

import 'dart:ui' show Locale;

import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:go_router/go_router.dart';
import 'package:nota/app/routing.dart';
import 'package:note_details/note_details.dart'
    show lookupNoteDetailsLocalizations;
import 'package:quick_actions/quick_actions.dart';

/// Registers the "Dictate a note" quick action and routes it to a new note
/// that opens in dictation.
///
/// Titles are set from the app locale rather than the device locale so the
/// shortcut matches the language the user chose in preferences; call
/// [updateTitles] whenever that changes.
class AppQuickActions {
  AppQuickActions({required GoRouter router, QuickActions? quickActions})
    : _router = router,
      _quickActions = quickActions ?? const QuickActions();

  static const dictateType = 'dictate';

  /// Name of the mic drawable (Android) and image set (iOS).
  static const _icon = 'ic_dictate';

  final GoRouter _router;
  final QuickActions _quickActions;

  /// Starts listening for quick action launches. Also delivers the action
  /// the app was cold-started with, so it runs after the first frame when
  /// the navigator exists.
  Future<void> install() => _quickActions.initialize(_handle);

  Future<void> updateTitles(Locale locale) {
    final l10n = lookupNoteDetailsLocalizations(locale);
    return _quickActions.setShortcutItems([
      ShortcutItem(
        type: dictateType,
        localizedTitle: l10n.dictateNote,
        icon: _icon,
      ),
    ]);
  }

  void _handle(String type) {
    if (type != dictateType) return;
    // Pushing keeps whatever the user had open underneath, so a note being
    // edited when the shortcut fires is not lost.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _router.push(AppRoutes.newVoiceNote);
    });
  }
}
