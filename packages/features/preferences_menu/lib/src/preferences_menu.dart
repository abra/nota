import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preferences_service/preferences_service.dart';
import 'package:shared/shared.dart';

import 'l10n/preferences_localizations.dart';
import 'preferences_cubit.dart';

enum _Page { main, language }

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
  });

  final PreferencesService service;
  final List<SupportedLanguage> supportedLanguages;

  /// Shown in the footer as "Version x.y.z" when provided.
  final String? appVersion;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PreferencesCubit(service: service),
      child: _PreferencesMenuView(
        supportedLanguages: supportedLanguages,
        appVersion: appVersion,
      ),
    );
  }
}

class _PreferencesMenuView extends StatefulWidget {
  const _PreferencesMenuView({
    required this.supportedLanguages,
    required this.appVersion,
  });

  final List<SupportedLanguage> supportedLanguages;
  final String? appVersion;

  @override
  State<_PreferencesMenuView> createState() => _PreferencesMenuViewState();
}

class _PreferencesMenuViewState extends State<_PreferencesMenuView> {
  _Page _page = _Page.main;

  void _goToLanguage() => setState(() => _page = _Page.language);

  void _goToMain() => setState(() => _page = _Page.main);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: _slideTransition,
          child: _page == _Page.main
              ? _MainPage(
                  key: const ValueKey(_Page.main),
                  supportedLanguages: widget.supportedLanguages,
                  appVersion: widget.appVersion,
                  onLanguageTap: _goToLanguage,
                )
              : _LanguagePage(
                  key: const ValueKey(_Page.language),
                  selectedCode: context
                      .read<PreferencesCubit>()
                      .state
                      .locale
                      .languageCode,
                  supportedLanguages: widget.supportedLanguages,
                  onSelected: (code) {
                    HapticFeedback.selectionClick();
                    context.read<PreferencesCubit>().update(
                      (p) => p.copyWith(locale: Locale(code)),
                    );
                    _goToMain();
                  },
                  onBack: _goToMain,
                ),
        ),
      ),
    );
  }

  /// Language page always slides in from the right / out to the right.
  /// Main page always slides in from the left / out to the left.
  /// This naturally handles both forward and backward transitions
  /// without tracking direction explicitly.
  static Widget _slideTransition(Widget child, Animation<double> animation) {
    final isLanguagePage = child.key == const ValueKey(_Page.language);
    final beginOffset = isLanguagePage
        ? const Offset(1, 0)
        : const Offset(-1, 0);
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
  });

  final List<SupportedLanguage> supportedLanguages;
  final String? appVersion;
  final VoidCallback onLanguageTap;

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
            _PreferenceGroup(
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
                  control: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedLanguage.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: Spacing.xSmall),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: IconSize.medium,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.medium),
            _PreferenceGroup(
              children: [
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

/// Scrollable list of supported languages with a checkmark
/// on the currently selected one.
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
    final l10n = PreferencesLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                Text(l10n.language, style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: Spacing.mediumLarge),
            _PreferenceGroup(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: Spacing.xSmall),
                  itemCount: supportedLanguages.length,
                  separatorBuilder: (_, _) => Divider(
                    indent: Spacing.mediumLarge,
                    endIndent: Spacing.mediumLarge,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                  itemBuilder: (context, index) {
                    final lang = supportedLanguages[index];
                    final isSelected = lang.code == selectedCode;
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Spacing.mediumLarge,
                      ),
                      title: Text(
                        lang.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              size: IconSize.medium,
                              color: colorScheme.primary,
                            )
                          : null,
                      onTap: () => onSelected(lang.code),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded container that groups related rows, separated by hairlines.
class _PreferenceGroup extends StatelessWidget {
  const _PreferenceGroup({this.children, this.child})
    : assert(children != null || child != null);

  final List<Widget>? children;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final rows = children;
    // Material (not DecoratedBox) so ListTile and InkWell splashes stay visible.
    return Material(
      color: isDark
          ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.6)
          : colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.mediumLarge)),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          child ??
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < rows!.length; i++) ...[
                if (i > 0)
                  Divider(
                    indent: Spacing.mediumLarge,
                    endIndent: Spacing.mediumLarge,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                rows[i],
              ],
            ],
          ),
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
