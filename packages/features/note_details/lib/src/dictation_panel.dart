part of 'note_details_screen.dart';

/// Secondary toolbar panel for dictation.
///
/// Two rows on the [FloatingBar] grid: a level meter with the live transcript
/// (or a status line) on top; mode toggles, return and microphone below.
/// Reads its [DictationCubit] from the widget tree.
class _DictationPanel extends StatelessWidget {
  const _DictationPanel({this.onOpenSettings, this.onPickLanguage});

  /// Shown as a "Settings" action when the permission was denied.
  final OpenAppSettings? onOpenSettings;

  /// Opens the dictation language picker from the language badge.
  final VoidCallback? onPickLanguage;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DictationCubit>();
    return FloatingPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: FloatingBar.controlSize,
            // Partial transcripts arrive several times a second, so only this
            // row rebuilds on every state change.
            child: BlocBuilder<DictationCubit, DictationState>(
              builder: (context, state) => Row(
                children: [
                  SizedBox.square(
                    dimension: FloatingBar.controlSize,
                    child: Center(
                      child: _DictationLevelIndicator(
                        level: cubit.soundLevel,
                        status: state.status,
                      ),
                    ),
                  ),
                  Expanded(child: _DictationTranscript(state: state)),
                  if (state.problem == DictationProblem.permissionDenied) ...[
                    if (onOpenSettings != null)
                      TextButton(
                        onPressed: onOpenSettings,
                        child: Text(
                          NoteDetailsLocalizations.of(context)!.openSettings,
                        ),
                      )
                    else
                      const SizedBox(width: Spacing.small),
                  ] else if (state.language case final language?
                      when onPickLanguage != null)
                    _DictationLanguageButton(
                      tag: language,
                      onPressed: onPickLanguage!,
                    )
                  else
                    const SizedBox(width: Spacing.small),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.small),
          BlocSelector<
            DictationCubit,
            DictationState,
            ({DictationMode mode, DictationStatus status})
          >(
            selector: (state) => (mode: state.mode, status: state.status),
            builder: (context, view) => _DictationControls(
              mode: view.mode,
              status: view.status,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom row of the dictation panel.
class _DictationControls extends StatelessWidget {
  const _DictationControls({required this.mode, required this.status});

  final DictationMode mode;
  final DictationStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = NoteDetailsLocalizations.of(context)!;
    final cubit = context.read<DictationCubit>();
    final isListening = status == DictationStatus.listening;
    return Row(
      children: [
        for (final option in DictationMode.values)
          FloatingBarButton(
            tooltip: _modeLabel(l10n, option),
            icon: _modeIcon(option),
            active: option == mode,
            onPressed: () {
              HapticFeedback.selectionClick();
              cubit.setMode(option);
            },
          ),
        const Spacer(),
        FloatingBarButton(
          tooltip: l10n.newLine,
          icon: Icons.keyboard_return_rounded,
          onPressed: cubit.newLine,
        ),
        FloatingBarButton(
          tooltip: isListening ? l10n.dictationPause : l10n.dictationResume,
          icon: isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
          filled: isListening,
          onPressed: status == DictationStatus.starting
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  if (isListening) {
                    cubit.stop();
                  } else {
                    cubit.start(Localizations.localeOf(context));
                  }
                },
        ),
      ],
    );
  }

  static String _modeLabel(NoteDetailsLocalizations l10n, DictationMode mode) =>
      switch (mode) {
        DictationMode.text => l10n.dictationModeText,
        DictationMode.list => l10n.dictationModeList,
        DictationMode.checklist => l10n.dictationModeChecklist,
      };

  static IconData _modeIcon(DictationMode mode) => switch (mode) {
    DictationMode.text => Icons.notes_rounded,
    DictationMode.list => Icons.format_list_bulleted_rounded,
    DictationMode.checklist => Icons.checklist_rounded,
  };
}

/// Badge with the dictation language code ("RU"), styled like a keyboard
/// key; opens the language picker.
class _DictationLanguageButton extends StatelessWidget {
  const _DictationLanguageButton({required this.tag, required this.onPressed});

  final String tag;
  final VoidCallback onPressed;

  // Corner of a keyboard key at this size.
  static const _radius = BorderRadius.all(Radius.circular(6));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return FloatingBarButton(
      tooltip: NoteDetailsLocalizations.of(context)!.dictationLanguage,
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.6), width: 1.2),
          borderRadius: _radius,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xSmall,
            vertical: 1,
          ),
          child: Text(
            DictationLanguage.languageCodeOf(tag).toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Picker for the dictation language: the current and recently used
/// languages first, then every other language the recogniser offers, by
/// name. Pops with the picked [DictationLanguage].
class _DictationLanguageSheet extends StatefulWidget {
  const _DictationLanguageSheet({
    required this.languages,
    required this.selectedTag,
    required this.recentTags,
  });

  final Future<List<DictationLanguage>> languages;
  final String? selectedTag;
  final List<String> recentTags;

  @override
  State<_DictationLanguageSheet> createState() =>
      _DictationLanguageSheetState();
}

class _DictationLanguageSheetState extends State<_DictationLanguageSheet> {
  // Shown while the recogniser lists its languages, so the sheet does not
  // jump from a sliver to its full height.
  static const _loadingHeight = 160.0;

  @override
  Widget build(BuildContext context) {
    final l10n = NoteDetailsLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.large,
          Spacing.small,
          Spacing.large,
          Spacing.large,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BottomSheetHeader(
              title: l10n.dictationLanguage,
              onClose: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: Spacing.mediumLarge),
            FutureBuilder<List<DictationLanguage>>(
              future: widget.languages,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    height: _loadingHeight,
                    child: CenteredCircularProgressIndicator(),
                  );
                }
                final languages = snapshot.data ?? const [];
                if (languages.isEmpty) {
                  return Text(
                    l10n.dictationLanguagesUnavailable,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return _list(context, languages);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, List<DictationLanguage> languages) {
    final l10n = NoteDetailsLocalizations.of(context)!;
    final byTag = {for (final language in languages) language.tag: language};
    final arranged = arrangeDictationLanguages(
      available: languages,
      // The current language leads even when it was never picked by hand,
      // so the checkmark is in sight.
      recentTags: [?widget.selectedTag, ...widget.recentTags],
    );
    List<Choice<String?>> choicesOf(List<DictationLanguage> list) => [
      for (final language in list)
        Choice(value: language.tag, label: language.name),
    ];
    return ChoiceList<String?>(
      maxHeight: MediaQuery.sizeOf(context).height * 0.6,
      sections: [
        ChoiceSection(
          title: l10n.dictationLanguagesRecent,
          choices: choicesOf(arranged.recent),
        ),
        ChoiceSection(
          title: arranged.recent.isEmpty ? null : l10n.dictationLanguagesAll,
          choices: choicesOf(arranged.others),
        ),
      ],
      selected: widget.selectedTag,
      onSelected: (tag) => Navigator.of(context).pop(byTag[tag]),
    );
  }
}

/// Live transcript, or the status line when there is nothing to show yet.
///
/// A long transcript may grow taller than the row; it is aligned to the
/// bottom and clipped at the top so the newest words stay visible.
class _DictationTranscript extends StatelessWidget {
  const _DictationTranscript({required this.state});

  final DictationState state;

  @override
  Widget build(BuildContext context) {
    final l10n = NoteDetailsLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final (text, color) = switch (state.status) {
      DictationStatus.starting => (
        l10n.dictationStarting,
        colorScheme.onSurfaceVariant,
      ),
      DictationStatus.idle => (
        l10n.dictationPaused,
        colorScheme.onSurfaceVariant,
      ),
      DictationStatus.failed => (
        _problemText(l10n, state.problem),
        colorScheme.error,
      ),
      DictationStatus.listening when state.partialText.isNotEmpty => (
        state.partialText,
        colorScheme.onSurface,
      ),
      DictationStatus.listening => (
        _listeningHint(l10n, state),
        colorScheme.onSurfaceVariant,
      ),
    };
    return ClipRect(
      child: OverflowBox(
        alignment: AlignmentDirectional.bottomStart,
        minHeight: FloatingBar.controlSize,
        maxHeight: double.infinity,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              height: 1.25,
            ),
          ),
        ),
      ),
    );
  }

  static String _listeningHint(
    NoteDetailsLocalizations l10n,
    DictationState state,
  ) {
    if (state.mode.isList) return l10n.dictationHintList;
    final phrase = state.newLinePhrase;
    return phrase == null
        ? l10n.dictationListening
        : l10n.dictationHintNewLine(phrase);
  }

  static String _problemText(
    NoteDetailsLocalizations l10n,
    DictationProblem? problem,
  ) => switch (problem) {
    DictationProblem.permissionDenied => l10n.dictationPermissionDenied,
    DictationProblem.unavailable => l10n.dictationUnavailable,
    DictationProblem.languageUnsupported => l10n.dictationLanguageUnsupported,
    DictationProblem.network => l10n.dictationNetworkError,
    DictationProblem.unknown || null => l10n.dictationFailed,
  };
}

/// Microphone glyph whose halo follows the input level while listening.
///
/// Levels change many times a second, so the meter listens to the cubit's
/// [ValueNotifier] directly and repaints in its own layer.
class _DictationLevelIndicator extends StatelessWidget {
  const _DictationLevelIndicator({required this.level, required this.status});

  final ValueListenable<double> level;
  final DictationStatus status;

  static const _haloSize = 28.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case DictationStatus.starting:
        return SizedBox.square(
          dimension: IconSize.small,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        );
      case DictationStatus.failed:
        return Icon(
          Icons.mic_off_rounded,
          size: IconSize.medium,
          color: colorScheme.error,
        );
      case DictationStatus.idle:
        return Icon(
          Icons.mic_none_rounded,
          size: IconSize.medium,
          color: colorScheme.onSurfaceVariant,
        );
      case DictationStatus.listening:
        return RepaintBoundary(
          child: ValueListenableBuilder<double>(
            valueListenable: level,
            child: Icon(
              Icons.mic_rounded,
              size: IconSize.medium,
              color: colorScheme.primary,
            ),
            builder: (context, value, icon) => Stack(
              alignment: Alignment.center,
              children: [
                AnimatedScale(
                  scale: 0.8 + value * 0.6,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withValues(alpha: 0.16),
                    ),
                    child: const SizedBox.square(dimension: _haloSize),
                  ),
                ),
                icon!,
              ],
            ),
          ),
        );
    }
  }
}
