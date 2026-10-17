import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'note_list_localizations_ar.dart';
import 'note_list_localizations_de.dart';
import 'note_list_localizations_en.dart';
import 'note_list_localizations_es.dart';
import 'note_list_localizations_fr.dart';
import 'note_list_localizations_hi.dart';
import 'note_list_localizations_ja.dart';
import 'note_list_localizations_pt.dart';
import 'note_list_localizations_ru.dart';
import 'note_list_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of NoteListLocalizations
/// returned by `NoteListLocalizations.of(context)`.
///
/// Applications need to include `NoteListLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/note_list_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: NoteListLocalizations.localizationsDelegates,
///   supportedLocales: NoteListLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the NoteListLocalizations.supportedLocales
/// property.
abstract class NoteListLocalizations {
  NoteListLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static NoteListLocalizations? of(BuildContext context) {
    return Localizations.of<NoteListLocalizations>(
      context,
      NoteListLocalizations,
    );
  }

  static const LocalizationsDelegate<NoteListLocalizations> delegate =
      _NoteListLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selected(int count);

  /// No description provided for @notesDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Note deleted} other{{count} notes deleted}}'**
  String notesDeleted(int count);

  /// No description provided for @emptyState.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get emptyState;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @noteDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete note'**
  String get noteDeleteFailed;

  /// No description provided for @noteUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update note'**
  String get noteUpdateFailed;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notes'**
  String get loadFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get noResults;

  /// No description provided for @noResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get noResultsHint;

  /// No description provided for @emptyStateHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first note'**
  String get emptyStateHint;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get addNote;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noteRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore note'**
  String get noteRestoreFailed;
}

class _NoteListLocalizationsDelegate
    extends LocalizationsDelegate<NoteListLocalizations> {
  const _NoteListLocalizationsDelegate();

  @override
  Future<NoteListLocalizations> load(Locale locale) {
    return SynchronousFuture<NoteListLocalizations>(
      lookupNoteListLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_NoteListLocalizationsDelegate old) => false;
}

NoteListLocalizations lookupNoteListLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return NoteListLocalizationsAr();
    case 'de':
      return NoteListLocalizationsDe();
    case 'en':
      return NoteListLocalizationsEn();
    case 'es':
      return NoteListLocalizationsEs();
    case 'fr':
      return NoteListLocalizationsFr();
    case 'hi':
      return NoteListLocalizationsHi();
    case 'ja':
      return NoteListLocalizationsJa();
    case 'pt':
      return NoteListLocalizationsPt();
    case 'ru':
      return NoteListLocalizationsRu();
    case 'zh':
      return NoteListLocalizationsZh();
  }

  throw FlutterError(
    'NoteListLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
