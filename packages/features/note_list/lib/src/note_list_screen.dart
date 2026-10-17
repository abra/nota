import 'package:component_library/component_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_files/image_files.dart';
import 'package:note_repository/note_repository.dart';
import 'package:preferences_service/preferences_service.dart';
import 'package:shared/shared.dart';
import 'package:smart_keyboard_insets/smart_keyboard_insets.dart';
import 'package:toast_service/toast_service.dart';

import 'l10n/note_list_localizations.dart';
import 'note_date_format.dart';
import 'note_list_bloc.dart';
import 'note_section_header.dart';
import 'note_sliver_grid.dart';
import 'note_sliver_list.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({
    super.key,
    required this.noteRepository,
    required this.preferencesService,
    required this.imageFiles,
    this.onNotePressed,
    this.onAddPressed,
    this.onSettingsPressed,
  });

  final NoteRepository noteRepository;
  final PreferencesService preferencesService;
  final ImageFiles imageFiles;
  final Future<Note?> Function(Note)? onNotePressed;
  final Future<Note?> Function()? onAddPressed;
  final void Function(BuildContext)? onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NoteListBloc>(
      create: (_) => NoteListBloc(
        noteRepository: noteRepository,
        preferencesService: preferencesService,
        imageFiles: imageFiles,
      )..add(NoteListStarted()),
      child: NoteListView(
        onNotePressed: onNotePressed,
        onAddPressed: onAddPressed,
        onSettingsPressed: onSettingsPressed,
      ),
    );
  }
}

@visibleForTesting
class NoteListView extends StatelessWidget {
  const NoteListView({
    super.key,
    this.onNotePressed,
    this.onAddPressed,
    this.onSettingsPressed,
  });

  final Future<Note?> Function(Note)? onNotePressed;
  final Future<Note?> Function()? onAddPressed;
  final void Function(BuildContext)? onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<NoteListBloc, NoteListState>(
          listenWhen: (prev, curr) =>
              prev.operationFailure != curr.operationFailure &&
              curr.operationFailure != null,
          listener: (context, state) {
            final l10n = NoteListLocalizations.of(context)!;
            final message = switch (state.operationFailure!.operation) {
              NoteListFailedOperation.delete => l10n.noteDeleteFailed,
              NoteListFailedOperation.update => l10n.noteUpdateFailed,
              NoteListFailedOperation.restore => l10n.noteRestoreFailed,
            };
            showToast(context, type: NotificationType.error, message: message);
          },
        ),
        BlocListener<NoteListBloc, NoteListState>(
          listenWhen: (prev, curr) =>
              prev.lastDeleted != curr.lastDeleted &&
              curr.lastDeleted != null &&
              curr.lastDeleted!.isNotEmpty,
          listener: (context, state) {
            final l10n = NoteListLocalizations.of(context)!;
            final bloc = context.read<NoteListBloc>();
            showToast(
              context,
              type: NotificationType.success,
              message: l10n.notesDeleted(state.lastDeleted!.length),
              action: ToastAction(
                label: l10n.undo,
                onPressed: () => bloc.add(NoteListUndoDeleteRequested()),
              ),
            );
          },
        ),
      ],
      child: BlocBuilder<NoteListBloc, NoteListState>(
        buildWhen: (prev, curr) =>
            prev.status != curr.status ||
            prev.notes != curr.notes ||
            prev.selectedIds != curr.selectedIds ||
            prev.query != curr.query ||
            prev.noteViewMode != curr.noteViewMode ||
            prev.noteListDensity != curr.noteListDensity,
        builder: (context, state) => _NoteListScaffold(
          state: state,
          onNotePressed: onNotePressed,
          onAddPressed: onAddPressed,
          onSettingsPressed: onSettingsPressed,
        ),
      ),
    );
  }
}

// ─── Layout constants ─────────────────────────────────────────────────────────

// Floating bars share the FloatingBar grid with the editor toolbar.
const double _kBarMargin = FloatingBar.margin;

// Scroll clearance so the last note is never hidden behind the floating bar.
const double _kBottomClearance = FloatingBar.clearance;

// Converts KeyboardMetrics into a logical-pixel inset for positioning UI above
// the keyboard. On Android the plugin measures from the physical screen bottom
// (includes nav bar), so safeAreaBottom is subtracted. On iOS safeAreaBottom
// is the static home-indicator height that the safe-area padding already
// accounts for.
double _keyboardInsetFor(KeyboardMetrics metrics) {
  if (!metrics.isKeyboardVisible) return 0.0;
  return defaultTargetPlatform == TargetPlatform.android
      ? metrics.keyboardHeight - metrics.safeAreaBottom
      : metrics.keyboardHeight;
}

// ─── Scaffold ─────────────────────────────────────────────────────────────────

class _NoteListScaffold extends StatelessWidget {
  const _NoteListScaffold({
    required this.state,
    this.onNotePressed,
    this.onAddPressed,
    this.onSettingsPressed,
  });

  final NoteListState state;
  final Future<Note?> Function(Note)? onNotePressed;
  final Future<Note?> Function()? onAddPressed;
  final void Function(BuildContext)? onSettingsPressed;

  Future<void> _openNote(BuildContext context, Note note) async {
    final updated = await onNotePressed!(note);
    if (!context.mounted) return;
    if (updated != null) {
      context.read<NoteListBloc>().add(NoteListNoteUpdated(updated));
    } else {
      context.read<NoteListBloc>().add(NoteListNoteRemoved(note.id));
    }
  }

  Future<void> _addNote(BuildContext context) async {
    final created = await onAddPressed!();
    if (!context.mounted) return;
    if (created != null) {
      context.read<NoteListBloc>().add(NoteListNoteAdded(created));
    }
  }

  void _toggleSelection(BuildContext context, String id) {
    HapticFeedback.selectionClick();
    context.read<NoteListBloc>().add(NoteListSelectionToggled(id));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NoteListBloc>();
    final l10n = NoteListLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Mirrors SafeArea semantics: shrinks to zero while the keyboard is open.
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    // Derived data is computed once per build and handed down.
    final filtered = state.filteredNotes;
    final dateFormatter = NoteDateFormatter(
      locale: Localizations.localeOf(context).toLanguageTag(),
      yesterdayLabel: l10n.yesterday,
    );
    final selectedNotes = state.notes.where(
      (n) => state.selectedIds.contains(n.id),
    );
    final allSelectedPinned =
        selectedNotes.isNotEmpty && selectedNotes.every((n) => n.isPinned);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<KeyboardMetrics>(
        stream: SmartKeyboardInsets.instance.metricsStream,
        initialData: KeyboardMetrics.hidden,
        builder: (context, snapshot) {
          final keyboardInset = _keyboardInsetFor(
            snapshot.data ?? KeyboardMetrics.hidden,
          );
          final overlayHeight = _kBottomClearance + keyboardInset + safeBottom;
          final isScrollable =
              state.status == NoteListStatus.success &&
              (filtered.isNotEmpty || state.isSelectionMode);

          return Stack(
            children: [
              CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverAppBar.medium(
                    title: const _AppTitle(),
                    scrolledUnderElevation: 3,
                    shadowColor: Colors.black.withValues(alpha: 0.18),
                  ),
                  ..._buildBody(
                    context,
                    l10n: l10n,
                    notes: filtered,
                    dateLabelFor: (note) =>
                        dateFormatter.format(note.updatedAt),
                    bottomClearance: overlayHeight,
                  ),
                  if (isScrollable)
                    SliverPadding(
                      padding: EdgeInsets.only(bottom: overlayHeight),
                    ),
                ],
              ),
              FadeGradientOverlay(height: overlayHeight),
              Positioned(
                left: _kBarMargin,
                right: _kBarMargin,
                bottom: _kBarMargin + keyboardInset + safeBottom,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.96,
                        end: 1,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: state.isSelectionMode
                      ? _SelectionBar(
                          key: const ValueKey('selection-bar'),
                          selectedCount: state.selectedIds.length,
                          allPinned: allSelectedPinned,
                          onCancel: () => bloc.add(NoteListSelectionCleared()),
                          onDelete: () {
                            HapticFeedback.mediumImpact();
                            bloc.add(NoteListSelectedDeleted());
                          },
                          onPinToggle: () =>
                              bloc.add(NoteListSelectedPinToggled()),
                        )
                      : _BottomBar(
                          key: const ValueKey('bottom-bar'),
                          initialQuery: state.query,
                          onAddPressed: onAddPressed == null
                              ? null
                              : () => _addNote(context),
                          onQueryChanged: (q) =>
                              bloc.add(NoteListQueryChanged(q)),
                          onSettingsPressed: onSettingsPressed,
                        ),
                ),
              ),
            ],
          );
        },
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
    );
  }

  List<Widget> _buildBody(
    BuildContext context, {
    required NoteListLocalizations l10n,
    required List<Note> notes,
    required String Function(Note) dateLabelFor,
    required double bottomClearance,
  }) {
    Widget fill(Widget child) => SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomClearance),
        child: child,
      ),
    );

    if (state.status == NoteListStatus.failure) {
      return [
        fill(
          ErrorState(
            message: l10n.loadFailed,
            retryLabel: l10n.retry,
            onRetry: () => context.read<NoteListBloc>().add(NoteListStarted()),
          ),
        ),
      ];
    }
    if (state.status != NoteListStatus.success) {
      return [fill(const CenteredCircularProgressIndicator())];
    }

    if (notes.isEmpty && !state.isSelectionMode) {
      return [
        fill(
          state.hasQuery
              ? EmptyState(
                  icon: Icons.search_off_rounded,
                  message: l10n.noResults,
                  hint: l10n.noResultsHint,
                )
              : EmptyState(
                  message: l10n.emptyState,
                  hint: l10n.emptyStateHint,
                ),
        ),
      ];
    }

    final pinned = <Note>[];
    final others = <Note>[];
    for (final note in notes) {
      (note.isPinned ? pinned : others).add(note);
    }
    final showSections = pinned.isNotEmpty && others.isNotEmpty;

    Widget group(List<Note> items) => SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: _kBarMargin),
      sliver: state.noteViewMode == NoteViewMode.grid
          ? NoteSliverGrid(
              notes: items,
              selectedIds: state.selectedIds,
              isSelectionMode: state.isSelectionMode,
              dateLabelFor: dateLabelFor,
              onNotePressed: onNotePressed == null
                  ? null
                  : (note) => _openNote(context, note),
              onNoteLongPressed: (id) => _toggleSelection(context, id),
            )
          : NoteSliverList(
              notes: items,
              density: state.noteListDensity,
              selectedIds: state.selectedIds,
              isSelectionMode: state.isSelectionMode,
              dateLabelFor: dateLabelFor,
              onNotePressed: onNotePressed == null
                  ? null
                  : (note) => _openNote(context, note),
              onNoteDeleted: (id) =>
                  context.read<NoteListBloc>().add(NoteListNoteDeleted(id)),
              onNoteLongPressed: (id) => _toggleSelection(context, id),
            ),
    );

    Widget header(String label) => SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: _kBarMargin),
      sliver: SliverToBoxAdapter(child: NoteSectionHeader(label: label)),
    );

    if (!showSections) {
      return [
        const SliverPadding(padding: EdgeInsets.only(top: Spacing.small)),
        group(notes),
      ];
    }
    return [
      header(l10n.pinned),
      group(pinned),
      header(l10n.others),
      group(others),
    ];
  }
}

// ─── App bar title ────────────────────────────────────────────────────────────

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NotaLogo(size: 22),
        SizedBox(width: Spacing.small + Spacing.xSmall),
        Text('Nota'),
      ],
    );
  }
}

// ─── Floating bars ────────────────────────────────────────────────────────────

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    super.key,
    required this.selectedCount,
    required this.allPinned,
    required this.onCancel,
    required this.onDelete,
    required this.onPinToggle,
  });

  final int selectedCount;
  final bool allPinned;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final VoidCallback onPinToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = NoteListLocalizations.of(context)!;
    final theme = Theme.of(context);
    return FloatingPanel(
      child: Row(
        children: [
          FloatingBarButton(
            icon: Icons.close,
            tooltip: l10n.cancel,
            onPressed: onCancel,
          ),
          const SizedBox(width: Spacing.small),
          Expanded(
            child: Text(
              l10n.selected(selectedCount),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const FloatingBarDivider(),
          FloatingBarButton(
            icon: allPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
            tooltip: l10n.pin,
            onPressed: onPinToggle,
          ),
          const SizedBox(width: Spacing.small),
          FloatingBarButton(
            icon: Icons.delete_outline,
            tooltip: l10n.delete,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatefulWidget {
  const _BottomBar({
    super.key,
    required this.initialQuery,
    this.onAddPressed,
    this.onQueryChanged,
    this.onSettingsPressed,
  });

  final String initialQuery;
  final Future<void> Function()? onAddPressed;
  final ValueChanged<String>? onQueryChanged;
  final void Function(BuildContext)? onSettingsPressed;

  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onQueryChanged?.call('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = NoteListLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final fieldColor = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerLow;

    return FloatingPanel(
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: FloatingBar.controlSize,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) => TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: widget.onQueryChanged,
                  textInputAction: TextInputAction.search,
                  textAlignVertical: TextAlignVertical.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: FloatingBar.iconSize,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    prefixIconConstraints: const BoxConstraints.tightFor(
                      width: FloatingBar.controlSize,
                      height: FloatingBar.controlSize,
                    ),
                    suffixIcon: value.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.cancel,
                            style: FloatingBar.buttonStyle.copyWith(
                              iconSize: const WidgetStatePropertyAll(
                                IconSize.small,
                              ),
                              foregroundColor: WidgetStatePropertyAll(
                                colorScheme.onSurfaceVariant,
                              ),
                            ),
                            icon: const Icon(Icons.close),
                            onPressed: _clear,
                          ),
                    suffixIconConstraints: const BoxConstraints.tightFor(
                      width: FloatingBar.controlSize,
                      height: FloatingBar.controlSize,
                    ),
                    filled: true,
                    fillColor: fieldColor,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: const OutlineInputBorder(
                      borderRadius: FloatingBar.controlRadius,
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: FloatingBar.controlRadius,
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: FloatingBar.controlRadius,
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const FloatingBarDivider(),
          FloatingBarButton(
            icon: Icons.menu,
            tooltip: l10n.menu,
            onPressed: widget.onSettingsPressed == null
                ? null
                : () => widget.onSettingsPressed!(context),
          ),
          const SizedBox(width: Spacing.small),
          FloatingBarButton(
            icon: Icons.add,
            tooltip: l10n.addNote,
            filled: true,
            onPressed: widget.onAddPressed,
          ),
        ],
      ),
    );
  }
}
