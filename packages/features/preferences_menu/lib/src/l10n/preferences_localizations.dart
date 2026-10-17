import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'preferences_localizations_ar.dart';
import 'preferences_localizations_de.dart';
import 'preferences_localizations_en.dart';
import 'preferences_localizations_es.dart';
import 'preferences_localizations_fr.dart';
import 'preferences_localizations_hi.dart';
import 'preferences_localizations_ja.dart';
import 'preferences_localizations_pt.dart';
import 'preferences_localizations_ru.dart';
import 'preferences_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of PreferencesLocalizations
/// returned by `PreferencesLocalizations.of(context)`.
///
/// Applications need to include `PreferencesLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/preferences_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: PreferencesLocalizations.localizationsDelegates,
///   supportedLocales: PreferencesLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the PreferencesLocalizations.supportedLocales
/// property.
abstract class PreferencesLocalizations {
  PreferencesLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static PreferencesLocalizations? of(BuildContext context) {
    return Localizations.of<PreferencesLocalizations>(
      context,
      PreferencesLocalizations,
    );
  }

  static const LocalizationsDelegate<PreferencesLocalizations> delegate =
      _PreferencesLocalizationsDelegate();

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

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @notesView.
  ///
  /// In en, this message translates to:
  /// **'Notes view'**
  String get notesView;

  /// No description provided for @listDensity.
  ///
  /// In en, this message translates to:
  /// **'List density'**
  String get listDensity;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @viewGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get viewGrid;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get viewList;

  /// No description provided for @linesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lines'**
  String linesCount(int count);

  /// No description provided for @dictationPause.
  ///
  /// In en, this message translates to:
  /// **'Pause between phrases'**
  String get dictationPause;

  /// No description provided for @pauseShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get pauseShort;

  /// No description provided for @pauseNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get pauseNormal;

  /// No description provided for @pauseLong.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get pauseLong;

  /// No description provided for @voiceCommands.
  ///
  /// In en, this message translates to:
  /// **'Voice commands'**
  String get voiceCommands;
}

class _PreferencesLocalizationsDelegate
    extends LocalizationsDelegate<PreferencesLocalizations> {
  const _PreferencesLocalizationsDelegate();

  @override
  Future<PreferencesLocalizations> load(Locale locale) {
    return SynchronousFuture<PreferencesLocalizations>(
      lookupPreferencesLocalizations(locale),
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
  bool shouldReload(_PreferencesLocalizationsDelegate old) => false;
}

PreferencesLocalizations lookupPreferencesLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return PreferencesLocalizationsAr();
    case 'de':
      return PreferencesLocalizationsDe();
    case 'en':
      return PreferencesLocalizationsEn();
    case 'es':
      return PreferencesLocalizationsEs();
    case 'fr':
      return PreferencesLocalizationsFr();
    case 'hi':
      return PreferencesLocalizationsHi();
    case 'ja':
      return PreferencesLocalizationsJa();
    case 'pt':
      return PreferencesLocalizationsPt();
    case 'ru':
      return PreferencesLocalizationsRu();
    case 'zh':
      return PreferencesLocalizationsZh();
  }

  throw FlutterError(
    'PreferencesLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
