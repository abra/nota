import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'note_details_localizations_ar.dart';
import 'note_details_localizations_de.dart';
import 'note_details_localizations_en.dart';
import 'note_details_localizations_es.dart';
import 'note_details_localizations_fr.dart';
import 'note_details_localizations_hi.dart';
import 'note_details_localizations_ja.dart';
import 'note_details_localizations_pt.dart';
import 'note_details_localizations_ru.dart';
import 'note_details_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of NoteDetailsLocalizations
/// returned by `NoteDetailsLocalizations.of(context)`.
///
/// Applications need to include `NoteDetailsLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/note_details_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: NoteDetailsLocalizations.localizationsDelegates,
///   supportedLocales: NoteDetailsLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the NoteDetailsLocalizations.supportedLocales
/// property.
abstract class NoteDetailsLocalizations {
  NoteDetailsLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static NoteDetailsLocalizations? of(BuildContext context) {
    return Localizations.of<NoteDetailsLocalizations>(
      context,
      NoteDetailsLocalizations,
    );
  }

  static const LocalizationsDelegate<NoteDetailsLocalizations> delegate =
      _NoteDetailsLocalizationsDelegate();

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

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get newNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleHint;

  /// No description provided for @contentHint.
  ///
  /// In en, this message translates to:
  /// **'Start typing...'**
  String get contentHint;

  /// No description provided for @noteNotFound.
  ///
  /// In en, this message translates to:
  /// **'Note not found'**
  String get noteNotFound;

  /// No description provided for @noteLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load note'**
  String get noteLoadFailed;

  /// No description provided for @noteSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save note'**
  String get noteSaveFailed;

  /// No description provided for @noteColor.
  ///
  /// In en, this message translates to:
  /// **'Note color'**
  String get noteColor;

  /// No description provided for @imageInsertFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to insert image'**
  String get imageInsertFailed;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get deleteNote;

  /// No description provided for @pinNote.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pinNote;

  /// No description provided for @unpinNote.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpinNote;

  /// No description provided for @editedAt.
  ///
  /// In en, this message translates to:
  /// **'Edited {date}'**
  String editedAt(String date);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreActions;

  /// No description provided for @formatting.
  ///
  /// In en, this message translates to:
  /// **'Formatting'**
  String get formatting;

  /// No description provided for @insertImage.
  ///
  /// In en, this message translates to:
  /// **'Insert image'**
  String get insertImage;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @newLine.
  ///
  /// In en, this message translates to:
  /// **'New line'**
  String get newLine;

  /// No description provided for @dictate.
  ///
  /// In en, this message translates to:
  /// **'Dictate'**
  String get dictate;

  /// No description provided for @dictationModeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get dictationModeText;

  /// No description provided for @dictationModeList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get dictationModeList;

  /// No description provided for @dictationModeChecklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get dictationModeChecklist;

  /// No description provided for @dictationStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting…'**
  String get dictationStarting;

  /// No description provided for @dictationListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get dictationListening;

  /// No description provided for @dictationPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused. Tap the microphone to continue'**
  String get dictationPaused;

  /// No description provided for @dictationHintList.
  ///
  /// In en, this message translates to:
  /// **'Listening… pause between items'**
  String get dictationHintList;

  /// No description provided for @dictationHintNewLine.
  ///
  /// In en, this message translates to:
  /// **'Listening… say “{phrase}” for a new line'**
  String dictationHintNewLine(String phrase);

  /// No description provided for @dictationPause.
  ///
  /// In en, this message translates to:
  /// **'Pause dictation'**
  String get dictationPause;

  /// No description provided for @dictationResume.
  ///
  /// In en, this message translates to:
  /// **'Resume dictation'**
  String get dictationResume;

  /// No description provided for @dictationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow microphone and speech recognition access in Settings'**
  String get dictationPermissionDenied;

  /// No description provided for @dictationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is not available on this device'**
  String get dictationUnavailable;

  /// No description provided for @dictationLanguageUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is not available for this language'**
  String get dictationLanguageUnsupported;

  /// No description provided for @dictationNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition needs a network connection'**
  String get dictationNetworkError;

  /// No description provided for @dictationFailed.
  ///
  /// In en, this message translates to:
  /// **'Dictation stopped because of an error'**
  String get dictationFailed;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get openSettings;

  /// No description provided for @dictateNote.
  ///
  /// In en, this message translates to:
  /// **'Dictate a note'**
  String get dictateNote;
}

class _NoteDetailsLocalizationsDelegate
    extends LocalizationsDelegate<NoteDetailsLocalizations> {
  const _NoteDetailsLocalizationsDelegate();

  @override
  Future<NoteDetailsLocalizations> load(Locale locale) {
    return SynchronousFuture<NoteDetailsLocalizations>(
      lookupNoteDetailsLocalizations(locale),
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
  bool shouldReload(_NoteDetailsLocalizationsDelegate old) => false;
}

NoteDetailsLocalizations lookupNoteDetailsLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return NoteDetailsLocalizationsAr();
    case 'de':
      return NoteDetailsLocalizationsDe();
    case 'en':
      return NoteDetailsLocalizationsEn();
    case 'es':
      return NoteDetailsLocalizationsEs();
    case 'fr':
      return NoteDetailsLocalizationsFr();
    case 'hi':
      return NoteDetailsLocalizationsHi();
    case 'ja':
      return NoteDetailsLocalizationsJa();
    case 'pt':
      return NoteDetailsLocalizationsPt();
    case 'ru':
      return NoteDetailsLocalizationsRu();
    case 'zh':
      return NoteDetailsLocalizationsZh();
  }

  throw FlutterError(
    'NoteDetailsLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
