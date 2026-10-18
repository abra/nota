import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preferences_service/preferences_service.dart';
import 'package:shared/shared.dart';

import 'l10n/preferences_localizations.dart';
import 'preferences_cubit.dart';

enum _Page { main, language, dictationLanguage }

/// App preferences menu. Creates [PreferencesCubit] and manages navigation
/// between the main settings page and the language selection page.
///
/// Designed to be shown with `showModalBottomSheet`; the sheet theme provides
/// the drag handle and rounded corners.
class PreferencesMenu extends StatelessWidget {
  const PreferencesMenu({
    super.key,
    required this.service,
    required this.supportedLanguages,
    this.appVersion,
    this.loadDictationLanguages,
  });

  final PreferencesService service;
  final List<SupportedLanguage> supportedLanguages;

  /// Shown in the footer as "Version x.y.z" when provided.
  final String? appVersion;

  /// Lists the languages the speech recogniser offers; the dictation
  /// language row is hidden without it.
  final Future<List<DictationLanguage>> Function()? loadDictationLanguages;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PreferencesCubit(service: service),
      child: _PreferencesMenuView(
        supportedLanguages: supportedLanguages,
        appVersion: appVersion,
        loadDictationLanguages: loadDictationLanguages,
      ),
    );
  }
}

class _PreferencesMenuView extends StatefulWidget {
  const _PreferencesMenuView({
    required this.supportedLanguages,
    required this.appVersion,
    required this.loadDictationLanguages,
  });

  final List<SupportedLanguage> supportedLanguages;
  final String? appVersion;
  final Future<List<DictationLanguage>> Function()? loadDictationLanguages;

  @override
  State<_PreferencesMenuView> createState() => _PreferencesMenuViewState();
}

class _PreferencesMenuViewState extends State<_PreferencesMenuView> {
  _Page _page = _Page.main;

  void _goTo(_Page page) => setState(() => _page = page);

  void _goToMain() => _goTo(_Page.main);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PreferencesCubit>();
    final loadDictationLanguages = widget.loadDictationLanguages;
    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: _slideTransition,
          child: switch (_page) {
            _Page.main => _MainPage(
              key: const ValueKey(_Page.main),
              supportedLanguages: widget.supportedLanguages,
              appVersion: widget.appVersion,
              onLanguageTap: () => _goTo(_Page.language),
              onDictationLanguageTap: loadDictationLanguages == null
                  ? null
                  : () => _goTo(_Page.dictationLanguage),
            ),
            _Page.language => _LanguagePage(
              key: const ValueKey(_Page.language),
              selectedCode: cubit.state.locale.languageCode,
              supportedLanguages: widget.supportedLanguages,
              onSelected: (code) {
                HapticFeedback.selectionClick();
                cubit.update((p) => p.copyWith(locale: Locale(code)));
                _goToMain();
              },
              onBack: _goToMain,
            ),
            _Page.dictationLanguage => _DictationLanguagePage(
              key: const ValueKey(_Page.dictationLanguage),
              load: loadDictationLanguages!,
              selectedTag: cubit.state.dictationLanguage?.tag,
              recentTags: cubit.state.recentDictationLanguages,
              onSelected: (language) {
                HapticFeedback.selectionClick();
                cubit.update((p) => p.withDictationLanguage(language));
                _goToMain();
              },
              onBack: _goToMain,
            ),
          },
        ),
      ),
    );
  }

  /// Sub-pages always slide in from the right / out to the right.
  /// Main page always slides in from the left / out to the left.
  /// This naturally handles both forward and backward transitions
  /// without tracking direction explicitly.
  static Widget _slideTransition(Widget child, Animation<double> animation) {
    final isSubPage = child.key != const ValueKey(_Page.main);
    final beginOffset = isSubPage ? const Offset(1, 0) : const Offset(-1, 0);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset * 0.25,
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

// Sheet content inset. The drag handle above comes from the sheet theme.
const _kSheetPadding = EdgeInsets.fromLTRB(
  Spacing.large,
  Spacing.small,
  Spacing.large,
  Spacing.large,
);

/// Reads current [Preferences] from [PreferencesCubit] and renders
/// theme, notes view, list density and language controls.
class _MainPage extends StatelessWidget {
  const _MainPage({
    super.key,
    required this.supportedLanguages,
    required this.appVersion,
    required this.onLanguageTap,
    required this.onDictationLanguageTap,
  });

  final List<SupportedLanguage> supportedLanguages;
  final String? appVersion;
  final VoidCallback onLanguageTap;
  final VoidCallback? onDictationLanguageTap;

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesCubit>().state;
    final cubit = context.read<PreferencesCubit>();
    final l10n = PreferencesLocalizations.of(context)!;
    final theme = Theme.of(context);
    final selectedLanguage = supportedLanguages.firstWhere(
      (l) => l.code == prefs.locale.languageCode,
      orElse: () => (
        code: prefs.locale.languageCode,
        name: prefs.locale.languageCode.toUpperCase(),
      ),
    );

    void update(Preferences Function(Preferences) transform) {
      HapticFeedback.selectionClick();
      cubit.update(transform);
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: _kSheetPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BottomSheetHeader(
              title: l10n.preferences,
              onClose: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: Spacing.mediumLarge),
            SettingsGroup(
              children: [
                _PreferenceRow(
                  icon: Icons.brightness_6_outlined,
                  label: l10n.theme,
                  control: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: const Icon(Icons.brightness_auto_outlined),
                        tooltip: l10n.themeSystem,
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode_outlined),
                        tooltip: l10n.themeLight,
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode_outlined),
                        tooltip: l10n.themeDark,
                      ),
                    ],
                    selected: {prefs.themeMode},
                    onSelectionChanged: (value) =>
                        update((p) => p.copyWith(themeMode: value.first)),
                  ),
                ),
                _PreferenceRow(
                  icon: Icons.dashboard_outlined,
                  label: l10n.notesView,
                  control: SegmentedButton<NoteViewMode>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: NoteViewMode.grid,
                        icon: const Icon(Icons.grid_view_rounded),
                        tooltip: l10n.viewGrid,
                      ),
                      ButtonSegment(
                        value: NoteViewMode.list,
                        icon: const Icon(Icons.view_agenda_outlined),
                        tooltip: l10n.viewList,
                      ),
                    ],
                    selected: {prefs.noteViewMode},
                    onSelectionChanged: (value) =>
                        update((p) => p.copyWith(noteViewMode: value.first)),
                  ),
                ),
                _PreferenceRow(
                  icon: Icons.density_medium_rounded,
                  label: l10n.listDensity,
                  control: SegmentedButton<NoteListDensity>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: NoteListDensity.twoLines,
                        label: const Text('2'),
                        tooltip: l10n.linesCount(2),
                      ),
                      ButtonSegment(
                        value: NoteListDensity.threeLines,
                        label: const Text('3'),
                        tooltip: l10n.linesCount(3),
                      ),
                      ButtonSegment(
                        value: NoteListDensity.fourLines,
                        label: const Text('4'),
                        tooltip: l10n.linesCount(4),
                      ),
                    ],
                    selected: {prefs.noteListDensity},
                    onSelectionChanged: (value) => update(
                      (p) => p.copyWith(noteListDensity: value.first),
                    ),
                  ),
                ),
                _PreferenceRow(
                  icon: Icons.language_rounded,
                  label: l10n.language,
                  onTap: onLanguageTap,
                  control: _ValueChevron(selectedLanguage.name),
                ),
              ],
            ),
            const SizedBox(height: Spacing.medium),
            SettingsGroup(
              children: [
                if (onDictationLanguageTap != null)
                  _PreferenceRow(
                    icon: Icons.translate_rounded,
                    label: l10n.dictationLanguage,
                    onTap: onDictationLanguageTap,
                    control: _ValueChevron(
                      prefs.dictationLanguage?.name ??
                          l10n.dictationLanguageApp,
                    ),
                  ),
                _PreferenceRow(
                  icon: Icons.mic_none_rounded,
                  label: l10n.dictationPause,
                  stacked: true,
                  control: SegmentedButton<DictationPause>(
                    showSelectedIcon: false,
                    expandedInsets: EdgeInsets.zero,
                    segments: [
                      ButtonSegment(
                        value: DictationPause.short,
                        label: Text(l10n.pauseShort),
                      ),
                      ButtonSegment(
                        value: DictationPause.normal,
                        label: Text(l10n.pauseNormal),
                      ),
                      ButtonSegment(
                        value: DictationPause.long,
                        label: Text(l10n.pauseLong),
                      ),
                    ],
                    selected: {prefs.dictationPause},
                    onSelectionChanged: (value) =>
                        update((p) => p.copyWith(dictationPause: value.first)),
                  ),
                ),
                _PreferenceRow(
                  icon: Icons.record_voice_over_outlined,
                  label: l10n.voiceCommands,
                  control: Switch(
                    value: prefs.voiceCommands,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (value) =>
                        update((p) => p.copyWith(voiceCommands: value)),
                  ),
                ),
              ],
            ),
            if (appVersion != null) ...[
              const SizedBox(height: Spacing.mediumLarge),
              Center(
                child: Text(
                  l10n.version(appVersion!),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Supported app languages with a checkmark on the selected one.
class _LanguagePage extends StatelessWidget {
  const _LanguagePage({
    super.key,
    required this.selectedCode,
    required this.supportedLanguages,
    required this.onSelected,
    required this.onBack,
  });

  final String selectedCode;
  final List<SupportedLanguage> supportedLanguages;
  final ValueChanged<String> onSelected;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _SubPage(
      title: PreferencesLocalizations.of(context)!.language,
      onBack: onBack,
      child: ChoiceList<String>(
        sections: [
          ChoiceSection(
            choices: [
              for (final language in supportedLanguages)
                Choice(value: language.code, label: language.name),
            ],
          ),
        ],
        selected: selectedCode,
        onSelected: onSelected,
      ),
    );
  }
}

/// Languages the speech recogniser offers: "same as app" first, then the
/// recently picked ones, then the rest by name.
///
/// The list comes from the recogniser, which may have to ask for microphone
/// access first; it is loaded once when the page opens.
class _DictationLanguagePage extends StatefulWidget {
  const _DictationLanguagePage({
    super.key,
    required this.load,
    required this.selectedTag,
    required this.recentTags,
    required this.onSelected,
    required this.onBack,
  });

  final Future<List<DictationLanguage>> Function() load;

  /// Tag of the chosen language; `null` follows the app language.
  final String? selectedTag;
  final List<String> recentTags;

  /// Called with the picked language, or `null` for "same as app".
  final ValueChanged<DictationLanguage?> onSelected;
  final VoidCallback onBack;

  @override
  State<_DictationLanguagePage> createState() => _DictationLanguagePageState();
}

class _DictationLanguagePageState extends State<_DictationLanguagePage> {
  late final Future<List<DictationLanguage>> _languages = widget.load();

  @override
  Widget build(BuildContext context) {
    final l10n = PreferencesLocalizations.of(context)!;
    final theme = Theme.of(context);
    return _SubPage(
      title: l10n.dictationLanguage,
      onBack: widget.onBack,
      child: FutureBuilder<List<DictationLanguage>>(
        future: _languages,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 120,
              child: CenteredCircularProgressIndicator(),
            );
          }
          final languages = snapshot.data ?? const [];
          final byTag = {for (final l in languages) l.tag: l};
          final arranged = arrangeDictationLanguages(
            available: languages,
            recentTags: widget.recentTags,
          );
          List<Choice<String?>> choicesOf(List<DictationLanguage> list) => [
            for (final language in list)
              Choice(value: language.tag, label: language.name),
          ];
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ChoiceList<String?>(
                maxHeight: 360,
                sections: [
                  ChoiceSection(
                    choices: [
                      Choice(value: null, label: l10n.dictationLanguageApp),
                    ],
                  ),
                  ChoiceSection(
                    title: l10n.dictationLanguagesRecent,
                    choices: choicesOf(arranged.recent),
                  ),
                  ChoiceSection(
                    title: l10n.dictationLanguagesAll,
                    choices: choicesOf(arranged.others),
                  ),
                ],
                selected: widget.selectedTag,
                onSelected: (tag) =>
                    widget.onSelected(tag == null ? null : byTag[tag]),
              ),
              if (languages.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.mediumLarge,
                    Spacing.medium,
                    Spacing.mediumLarge,
                    0,
                  ),
                  child: Text(
                    l10n.dictationLanguagesUnavailable,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Layout of a page reached from the main page: back button, title, content.
class _SubPage extends StatelessWidget {
  const _SubPage({
    required this.title,
    required this.onBack,
    required this.child,
  });

  final String title;
  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: _kSheetPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Shift the 40 px button so its glyph aligns with the sheet
                // edge like the title text on the main page.
                Transform.translate(
                  offset: const Offset(-Spacing.small, 0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.mediumLarge),
            child,
          ],
        ),
      ),
    );
  }
}

/// Current value of a row that opens a sub-page, followed by a chevron.
class _ValueChevron extends StatelessWidget {
  const _ValueChevron(this.value);

  final String value;

  // Recogniser names such as "Chinese, Mandarin (Simplified, China)" would
  // otherwise squeeze the row label.
  static const _maxValueWidth = 168.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxValueWidth),
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
        const SizedBox(width: Spacing.xSmall),
        Icon(Icons.chevron_right_rounded, size: IconSize.medium, color: color),
      ],
    );
  }
}

/// A single row: leading icon, label, and a control at the trailing edge.
///
/// With [stacked] the control takes a full-width line under the label, for
/// controls with text segments that would not fit beside long labels.
class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.icon,
    required this.label,
    required this.control,
    this.onTap,
    this.stacked = false,
  });

  final IconData icon;
  final String label;
  final Widget control;
  final VoidCallback? onTap;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final header = [
      Icon(icon, size: IconSize.medium, color: colorScheme.onSurfaceVariant),
      const SizedBox(width: Spacing.medium),
      Expanded(
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
    ];
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.mediumLarge,
        vertical: Spacing.medium,
      ),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: header),
                const SizedBox(height: Spacing.medium),
                control,
              ],
            )
          : Row(
              children: [
                ...header,
                const SizedBox(width: Spacing.small),
                control,
              ],
            ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}
