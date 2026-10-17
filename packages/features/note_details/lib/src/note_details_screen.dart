import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:component_library/component_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_files/image_files.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:note_repository/note_repository.dart';
import 'package:shared/shared.dart';
import 'package:smart_keyboard_insets/smart_keyboard_insets.dart';
import 'package:toast_service/toast_service.dart';

import 'l10n/note_details_localizations.dart';
import 'note_details_bloc.dart';
import 'quill_content.dart';

part 'note_color_picker.dart';

// ─── Layout constants ─────────────────────────────────────────────────────────

// The toolbar shares the FloatingBar grid with the note list's bottom bar so
// both screens feel like one app.
const double _kBarMargin = FloatingBar.margin;

// Secondary panel (formatting or colours) matches the primary toolbar height.
const double _kSecondaryPanelHeight = FloatingBar.height;

// Space reserved under the editor for the primary toolbar.
const double _kToolbarClearance = FloatingBar.clearance;

// Converts KeyboardMetrics into a logical-pixel inset for positioning UI above
// the keyboard. On Android the plugin measures from the physical screen bottom
// (includes nav bar), so safeAreaBottom is subtracted. On iOS safeAreaBottom
// is the static home-indicator height that SafeArea already handles.
double _keyboardInsetFor(KeyboardMetrics metrics) {
  if (!metrics.isKeyboardVisible) return 0.0;
  return defaultTargetPlatform == TargetPlatform.android
      ? metrics.keyboardHeight - metrics.safeAreaBottom
      : metrics.keyboardHeight;
}

enum _SecondaryPanelMode { formatting, colors }

enum _MenuAction { delete }

class NoteDetailsScreen extends StatelessWidget {
  const NoteDetailsScreen({
    super.key,
    required this.noteRepository,
    required this.imageFiles,
    this.noteId,
  });

  final NoteRepository noteRepository;
  final ImageFiles imageFiles;
  final String? noteId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NoteDetailsBloc>(
      create: (_) => NoteDetailsBloc(
        noteRepository: noteRepository,
        imageFiles: imageFiles,
        isNew: noteId == null,
      )..add(NoteDetailsStarted(noteId: noteId)),
      child: const NoteDetailsView(),
    );
  }
}

@visibleForTesting
class NoteDetailsView extends StatefulWidget {
  const NoteDetailsView({super.key});

  @override
  State<NoteDetailsView> createState() => _NoteDetailsViewState();
}

class _NoteDetailsViewState extends State<NoteDetailsView>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleController;

  // non-final: replaced on first note load
  late QuillController _quillController;
  late final FocusNode _quillFocusNode;
  late final ScrollController _quillScrollController;
  late final AnimationController _toolbarAnimController;
  late final Animation<double> _toolbarAnimation;
  StreamSubscription<DocChange>? _changesSub;
  bool _contentInitialized = false;
  _SecondaryPanelMode _activePanel = _SecondaryPanelMode.formatting;
  bool _isPanelOpen = false;

  // Disable rich-text paste from external apps: HTML from the clipboard
  // brings unwanted styles (background colors, font sizes, etc.).
  static const _controllerConfig = QuillControllerConfig(
    // ignore: experimental_member_use
    clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: false),
  );

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _quillController = QuillController.basic(config: _controllerConfig);
    _quillFocusNode = FocusNode();
    _quillScrollController = ScrollController();
    _toolbarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _toolbarAnimation = CurvedAnimation(
      parent: _toolbarAnimController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _subscribeToChanges();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _changesSub?.cancel();
    _quillController.dispose();
    _quillFocusNode.dispose();
    _quillScrollController.dispose();
    _toolbarAnimController.dispose();
    super.dispose();
  }

  void _subscribeToChanges() {
    _changesSub?.cancel();
    _changesSub = _quillController.changes.listen((change) {
      if (!mounted) return;
      if (change.source != ChangeSource.local) return;
      final json = jsonEncode({
        'ops': _quillController.document.toDelta().toJson(),
      });
      context.read<NoteDetailsBloc>().add(NoteDetailsContentChanged(json));
    });
  }

  QuillController _controllerFromContent(String content) {
    return QuillController(
      config: _controllerConfig,
      document: Document.fromJson(opsFromContent(content)),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  void _saveAndPop(BuildContext context) {
    final bloc = context.read<NoteDetailsBloc>();
    final state = bloc.state;

    // Ignore repeated back presses while a save or delete is in flight.
    if (state.isSaveInProgress) return;

    // The note never loaded (missing or storage error): nothing to save.
    if (!state.isNew && state.note == null) {
      Navigator.of(context).pop<Note?>(null);
      return;
    }

    if (state.isContentEmpty && state.title.trim().isEmpty) {
      if (!state.isNew) {
        bloc.add(NoteDetailsDeleteRequested());
      } else {
        Navigator.of(context).pop<Note?>(null);
      }
      return;
    }

    // For existing notes, skip save if nothing actually changed.
    if (!state.isNew && state.note != null) {
      final note = state.note!;
      final unchanged =
          state.title.trim() == (note.title ?? '') &&
          state.content == (state.originalContent ?? note.content) &&
          state.color == note.color &&
          state.isPinned == note.isPinned;
      if (unchanged) {
        Navigator.of(context).pop<Note?>(note);
        return;
      }
    }
    bloc.add(NoteDetailsSaved());
  }

  void _onMenuAction(BuildContext context, _MenuAction action) {
    switch (action) {
      case _MenuAction.delete:
        HapticFeedback.mediumImpact();
        final bloc = context.read<NoteDetailsBloc>();
        if (bloc.state.isNew) {
          // Nothing persisted yet: discard the draft.
          Navigator.of(context).pop<Note?>(null);
        } else {
          bloc.add(NoteDetailsDeleteRequested());
        }
    }
  }

  DefaultStyles _buildEditorStyles(BuildContext context) {
    const noH = HorizontalSpacing(0, 0);
    final bodyLarge = Theme.of(context).textTheme.bodyLarge!;
    final body = bodyLarge.copyWith(decoration: TextDecoration.none);
    final bodyWithHeight = body.copyWith(height: 1.5);
    final hintColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.38);
    return DefaultStyles(
      paragraph: DefaultTextBlockStyle(
        bodyWithHeight,
        noH,
        VerticalSpacing.zero,
        VerticalSpacing.zero,
        null,
      ),
      placeHolder: DefaultTextBlockStyle(
        bodyWithHeight.copyWith(color: hintColor),
        noH,
        VerticalSpacing.zero,
        VerticalSpacing.zero,
        null,
      ),
      leading: DefaultTextBlockStyle(
        body,
        noH,
        VerticalSpacing.zero,
        VerticalSpacing.zero,
        null,
      ),
      lists: DefaultListBlockStyle(
        body,
        noH,
        const VerticalSpacing(2, 0),
        VerticalSpacing.zero,
        null,
        null,
      ),
      bold: bodyLarge.copyWith(fontWeight: FontWeight.w600),
      italic: bodyLarge.copyWith(fontStyle: FontStyle.italic),
      underline: bodyLarge.copyWith(decoration: TextDecoration.underline),
      strikeThrough: bodyLarge.copyWith(
        decoration: TextDecoration.lineThrough,
      ),
    );
  }

  void _togglePanel(_SecondaryPanelMode mode) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_isPanelOpen && _activePanel == mode) {
        // Tapping the active button closes the panel.
        _isPanelOpen = false;
        _toolbarAnimController.reverse();
      } else {
        // Switch mode (content snaps instantly) or open if currently closed.
        _activePanel = mode;
        if (!_isPanelOpen) {
          _isPanelOpen = true;
          _toolbarAnimController.forward();
        }
      }
    });
  }

  Future<void> _pickImage(BuildContext context) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !context.mounted) return;
    context.read<NoteDetailsBloc>().add(NoteDetailsImageInserted(picked.path));
  }

  void _insertNewLine() {
    final offset = _quillController.selection.extentOffset;
    _quillController.replaceText(
      offset,
      0,
      '\n',
      TextSelection.collapsed(offset: offset + 1),
    );
  }

  String _formatEdited(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    try {
      return DateFormat.yMMMd(locale).add_Hm().format(date);
    } catch (_) {
      return DateFormat.yMMMd('en').add_Hm().format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoteDetailsBloc, NoteDetailsState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.insertedImagePath != curr.insertedImagePath ||
          prev.imageInsertError != curr.imageInsertError ||
          prev.loadError != curr.loadError ||
          prev.saveError != curr.saveError,
      buildWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.color != curr.color ||
          prev.isPinned != curr.isPinned ||
          prev.isNew != curr.isNew ||
          prev.note != curr.note,
      listener: (context, state) {
        final l10n = NoteDetailsLocalizations.of(context)!;

        if (state.insertedImagePath != null &&
            state.status != NoteDetailsStatus.saved &&
            state.status != NoteDetailsStatus.deleted) {
          final path = state.insertedImagePath!;
          final index = _quillController.selection.extentOffset;
          _quillController.document.insert(index, BlockEmbed.image(path));
          _quillController.document.insert(index + 1, '\n');
          _quillController.updateSelection(
            TextSelection.collapsed(offset: index + 2),
            ChangeSource.local,
          );
        }

        if (state.status == NoteDetailsStatus.success) {
          _titleController.text = state.title;
          if (!_contentInitialized) {
            _contentInitialized = true;
            final newController = _controllerFromContent(state.content);
            final oldController = _quillController;
            _changesSub?.cancel();
            _quillController = newController;
            _subscribeToChanges();
            // Defer disposal: the old QuillEditor is still in the tree and
            // holds a ChangeNotifier listener on oldController. Disposing it
            // synchronously triggers a '_count == 0' assertion in debug mode.
            // Disposing after the frame ensures the widget has rebuilt first.
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => oldController.dispose(),
            );
          }
        }

        if (state.status == NoteDetailsStatus.saved) {
          Navigator.of(context).pop<Note?>(state.note);
        }

        if (state.status == NoteDetailsStatus.deleted) {
          Navigator.of(context).pop<Note?>(null);
        }

        if (state.imageInsertError != null) {
          showToast(
            context,
            type: NotificationType.error,
            message: l10n.imageInsertFailed,
          );
        }

        // Only react to a failure that carries a fresh error; the status stays
        // `failure` on later emits, but the error fields are one-shot.
        if (state.status == NoteDetailsStatus.failure &&
            (state.loadError != null || state.saveError != null)) {
          final isNotFound = state.loadError is NoteNotFoundException;
          showToast(
            context,
            type: NotificationType.error,
            message: isNotFound
                ? l10n.noteNotFound
                : state.saveError != null
                ? l10n.noteSaveFailed
                : l10n.noteLoadFailed,
          );
        }
      },
      builder: (context, state) {
        final l10n = NoteDetailsLocalizations.of(context)!;
        final theme = Theme.of(context);
        final brightness = theme.brightness;
        final hasColor = state.color != NoteColor.none;
        final pageColor = hasColor
            ? state.color.forBrightness(brightness)
            : theme.scaffoldBackgroundColor;
        final foreground = hasColor
            ? state.color.onColorFor(brightness)
            : theme.colorScheme.onSurface;
        final editedAt = state.note?.updatedAt;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _saveAndPop(context);
          },
          // The page tint lives behind a transparent Scaffold so colour changes
          // can animate; the app bar is transparent for the same reason.
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            color: pageColor,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              appBar: _NoteDetailsAppBar(
                foregroundColor: foreground,
                isPinned: state.isPinned,
                onBack: () => _saveAndPop(context),
                onPinToggled: () {
                  HapticFeedback.selectionClick();
                  context.read<NoteDetailsBloc>().add(NoteDetailsPinToggled());
                },
                onMenuAction: (action) => _onMenuAction(context, action),
              ),
              body: SafeArea(
                top: false,
                child: StreamBuilder<KeyboardMetrics>(
                  stream: SmartKeyboardInsets.instance.metricsStream,
                  initialData: KeyboardMetrics.hidden,
                  builder: (context, snapshot) {
                    final keyboardInset = _keyboardInsetFor(
                      snapshot.data ?? KeyboardMetrics.hidden,
                    );
                    return Stack(
                      children: [
                        CustomScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                Spacing.large,
                                Spacing.small,
                                Spacing.large,
                                0,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      controller: _titleController,
                                      onChanged: (v) => context
                                          .read<NoteDetailsBloc>()
                                          .add(NoteDetailsTitleChanged(v)),
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(color: foreground),
                                      cursorColor: theme.colorScheme.primary,
                                      decoration: InputDecoration(
                                        hintText: l10n.titleHint,
                                        hintStyle: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              color: foreground.withValues(
                                                alpha: 0.38,
                                              ),
                                            ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: Spacing.xSmall,
                                            ),
                                      ),
                                      maxLines: null,
                                      keyboardType: TextInputType.text,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    if (editedAt != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: Spacing.xSmall,
                                          bottom: Spacing.small,
                                        ),
                                        child: Text(
                                          l10n.editedAt(
                                            _formatEdited(context, editedAt),
                                          ),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w400,
                                                color: foreground.withValues(
                                                  alpha: 0.55,
                                                ),
                                              ),
                                        ),
                                      )
                                    else
                                      const SizedBox(height: Spacing.small),
                                  ],
                                ),
                              ),
                            ),
                            SliverFillRemaining(
                              hasScrollBody: false,
                              // Bottom padding grows as the secondary panel
                              // slides in, keeping the last line of text above
                              // the toolbar stack.
                              child: AnimatedBuilder(
                                animation: _toolbarAnimation,
                                builder: (context, child) => Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    Spacing.large,
                                    0,
                                    Spacing.large,
                                    _kToolbarClearance +
                                        _toolbarAnimation.value *
                                            (_kSecondaryPanelHeight +
                                                Spacing.small) +
                                        keyboardInset,
                                  ),
                                  child: child,
                                ),
                                child: QuillEditor(
                                  controller: _quillController,
                                  focusNode: _quillFocusNode,
                                  scrollController: _quillScrollController,
                                  config: QuillEditorConfig(
                                    placeholder: l10n.contentHint,
                                    scrollable: false,
                                    expands: false,
                                    padding: EdgeInsets.zero,
                                    autoFocus: false,
                                    customStyles: _buildEditorStyles(context),
                                    embedBuilders: const [
                                      _LocalImageEmbedBuilder(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Gradient fade behind the toolbar so content scrolls
                        // under smoothly.
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: IgnorePointer(
                            child: AnimatedBuilder(
                              animation: _toolbarAnimation,
                              builder: (context, _) => Container(
                                height:
                                    _kToolbarClearance +
                                    _toolbarAnimation.value *
                                        (_kSecondaryPanelHeight +
                                            Spacing.small) +
                                    keyboardInset,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      pageColor.withValues(alpha: 0),
                                      pageColor,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: _kBarMargin,
                          right: _kBarMargin,
                          bottom: _kBarMargin + keyboardInset,
                          child: _NoteToolbar(
                            // Key forces a full rebuild when the controller is
                            // replaced (happens once, on first note load).
                            key: ObjectKey(_quillController),
                            controller: _quillController,
                            animation: _toolbarAnimation,
                            activePanel: _activePanel,
                            isSecondaryOpen: _isPanelOpen,
                            noteColor: state.color,
                            onToggleFormatting: () =>
                                _togglePanel(_SecondaryPanelMode.formatting),
                            onToggleColors: () =>
                                _togglePanel(_SecondaryPanelMode.colors),
                            onImagePressed: () => _pickImage(context),
                            onColorSelected: (color) {
                              HapticFeedback.selectionClick();
                              context.read<NoteDetailsBloc>().add(
                                NoteDetailsColorChanged(color),
                              );
                            },
                            onNewLine: _insertNewLine,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── App bar ──────────────────────────────────────────────────────────────────

// Transparent so the animated page tint behind the Scaffold shows through.
class _NoteDetailsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _NoteDetailsAppBar({
    required this.foregroundColor,
    required this.isPinned,
    required this.onBack,
    required this.onPinToggled,
    required this.onMenuAction,
  });

  final Color foregroundColor;
  final bool isPinned;
  final VoidCallback onBack;
  final VoidCallback onPinToggled;
  final ValueChanged<_MenuAction> onMenuAction;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = NoteDetailsLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      // A transparent bar cannot infer status-bar icon colour from its
      // background, so follow the theme brightness explicitly.
      systemOverlayStyle: theme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      leading: IconButton(
        tooltip: l10n.back,
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
      ),
      actions: [
        IconButton(
          tooltip: isPinned ? l10n.unpinNote : l10n.pinNote,
          icon: Icon(
            isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            color: isPinned ? colorScheme.primary : foregroundColor,
          ),
          onPressed: onPinToggled,
        ),
        PopupMenuButton<_MenuAction>(
          tooltip: l10n.moreActions,
          icon: Icon(Icons.more_horiz, color: foregroundColor),
          position: PopupMenuPosition.under,
          onSelected: onMenuAction,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _MenuAction.delete,
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: IconSize.medium,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: Spacing.medium),
                  Text(
                    l10n.deleteNote,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: Spacing.xSmall),
      ],
    );
  }
}

// ─── Toolbar ──────────────────────────────────────────────────────────────────

class _NoteToolbar extends StatelessWidget {
  const _NoteToolbar({
    super.key,
    required this.controller,
    required this.animation,
    required this.activePanel,
    required this.isSecondaryOpen,
    required this.noteColor,
    required this.onToggleFormatting,
    required this.onToggleColors,
    required this.onImagePressed,
    required this.onColorSelected,
    required this.onNewLine,
  });

  final QuillController controller;
  final Animation<double> animation;
  final _SecondaryPanelMode activePanel;
  final bool isSecondaryOpen;
  final NoteColor noteColor;
  final VoidCallback onToggleFormatting;
  final VoidCallback onToggleColors;
  final VoidCallback onImagePressed;
  final ValueChanged<NoteColor> onColorSelected;
  final VoidCallback onNewLine;

  @override
  Widget build(BuildContext context) {
    final l10n = NoteDetailsLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Secondary panel slides in above the primary toolbar.
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) => Align(
            alignment: Alignment.topCenter,
            heightFactor: animation.value,
            child: child,
          ),
          child: FadeTransition(
            opacity: animation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: Spacing.small),
              child: _SecondaryPanel(
                mode: activePanel,
                controller: controller,
                noteColor: noteColor,
                onColorSelected: onColorSelected,
              ),
            ),
          ),
        ),
        // Primary toolbar.
        FloatingPanel(
          child: Row(
            children: [
              // Undo / redo rebuild on every controller history change.
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingBarButton(
                      tooltip: l10n.undo,
                      icon: Icons.undo_rounded,
                      onPressed: controller.hasUndo ? controller.undo : null,
                    ),
                    FloatingBarButton(
                      tooltip: l10n.redo,
                      icon: Icons.redo_rounded,
                      onPressed: controller.hasRedo ? controller.redo : null,
                    ),
                  ],
                ),
              ),
              const FloatingBarDivider(),
              FloatingBarButton(
                tooltip: l10n.formatting,
                icon: Icons.text_format_rounded,
                active:
                    isSecondaryOpen &&
                    activePanel == _SecondaryPanelMode.formatting,
                onPressed: onToggleFormatting,
              ),
              FloatingBarButton(
                tooltip: l10n.insertImage,
                icon: Icons.image_outlined,
                onPressed: onImagePressed,
              ),
              FloatingBarButton(
                tooltip: l10n.noteColor,
                active:
                    isSecondaryOpen &&
                    activePanel == _SecondaryPanelMode.colors,
                onPressed: onToggleColors,
                child: _ColorCircleIcon(noteColor: noteColor),
              ),
              const Spacer(),
              FloatingBarButton(
                tooltip: l10n.newLine,
                icon: Icons.keyboard_return_rounded,
                onPressed: onNewLine,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Formatting panel ─────────────────────────────────────────────────────────

class _FormattingPanel extends StatelessWidget {
  const _FormattingPanel({required this.controller});

  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FloatingPanel(
      child: SizedBox(
        height: FloatingBar.controlSize,
        child: QuillSimpleToolbar(
          controller: controller,
          config: QuillSimpleToolbarConfig(
            multiRowsDisplay: false,
            toolbarSize: FloatingBar.controlSize,
            toolbarSectionSpacing: 0,
            toolbarIconAlignment: WrapAlignment.spaceBetween,
            color: Colors.transparent,
            buttonOptions: QuillSimpleToolbarButtonOptions(
              base: QuillToolbarBaseButtonOptions(
                iconSize: IconSize.medium,
                iconButtonFactor: FloatingBar.controlSize / IconSize.medium,
                iconTheme: QuillIconTheme(
                  iconButtonUnselectedData: IconButtonData(
                    style: FloatingBar.buttonStyle.copyWith(
                      iconSize: const WidgetStatePropertyAll(IconSize.medium),
                      foregroundColor: WidgetStatePropertyAll(
                        colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  iconButtonSelectedData: IconButtonData(
                    style: FloatingBar.buttonStyle.copyWith(
                      iconSize: const WidgetStatePropertyAll(IconSize.medium),
                      backgroundColor: WidgetStatePropertyAll(
                        colorScheme.primaryContainer,
                      ),
                      foregroundColor: WidgetStatePropertyAll(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Only the buttons we need; QuillSimpleToolbar shows
            // everything by default so the rest must be hidden explicitly.
            showBoldButton: true,
            showItalicButton: true,
            showUnderLineButton: true,
            showStrikeThrough: true,
            showListNumbers: true,
            showListBullets: true,
            showListCheck: true,
            showClearFormat: true,
            showUndo: false,
            showRedo: false,
            showDividers: false,
            showFontFamily: false,
            showFontSize: false,
            showInlineCode: false,
            showHeaderStyle: false,
            showCodeBlock: false,
            showQuote: false,
            showIndent: false,
            showLink: false,
            showSearchButton: false,
            showColorButton: false,
            showBackgroundColorButton: false,
            showSuperscript: false,
            showSubscript: false,
          ),
        ),
      ),
    );
  }
}

// ─── Shared panel widgets ─────────────────────────────────────────────────────

// Colour swatch used as the icon for the colour-picker toolbar button.
// Shows the current note colour; a palette glyph stands in for NoteColor.none.
class _ColorCircleIcon extends StatelessWidget {
  const _ColorCircleIcon({required this.noteColor});

  final NoteColor noteColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isNone = noteColor == NoteColor.none;
    if (isNone) {
      return const Icon(Icons.palette_outlined);
    }
    return Container(
      width: IconSize.medium,
      height: IconSize.medium,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: noteColor.forBrightness(theme.brightness),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
    );
  }
}

// Renders the correct secondary panel based on the active mode.
class _SecondaryPanel extends StatelessWidget {
  const _SecondaryPanel({
    required this.mode,
    required this.controller,
    required this.noteColor,
    required this.onColorSelected,
  });

  final _SecondaryPanelMode mode;
  final QuillController controller;
  final NoteColor noteColor;
  final ValueChanged<NoteColor> onColorSelected;

  @override
  Widget build(BuildContext context) => switch (mode) {
    _SecondaryPanelMode.formatting => _FormattingPanel(
      controller: controller,
    ),
    _SecondaryPanelMode.colors => _InlineColorPanel(
      selected: noteColor,
      onSelected: onColorSelected,
    ),
  };
}

// ─── Image embed ──────────────────────────────────────────────────────────────

// Renders local file images stored in nota_images/ inside the Quill editor.
class _LocalImageEmbedBuilder extends EmbedBuilder {
  const _LocalImageEmbedBuilder();

  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final path = embedContext.node.value.data as String;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.small),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(AppRadius.mediumLarge),
            ),
            child: Image.file(
              File(path),
              width: double.infinity,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => Container(
                height: 120,
                color: colorScheme.surfaceContainerHigh,
                alignment: Alignment.center,
                child: Icon(
                  Icons.broken_image_outlined,
                  size: IconSize.xLarge,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Positioned(
            top: Spacing.small,
            right: Spacing.small,
            child: Material(
              color: Colors.black.withValues(alpha: 0.55),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _removeEmbed(embedContext.controller, path),
                child: const Padding(
                  padding: EdgeInsets.all(Spacing.small - 2),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: IconSize.small,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeEmbed(QuillController controller, String path) {
    int offset = 0;
    for (final op in controller.document.toDelta().toList()) {
      if (op.data is Map && (op.data as Map)['image'] == path) {
        // Delete the embed (1 char) + the trailing newline (1 char).
        final docLength = controller.document.length;
        final deleteLen = (offset + 2 <= docLength) ? 2 : 1;
        controller.replaceText(offset, deleteLen, '', null);
        // The tap event propagates to Quill's gesture handler which resets
        // the cursor to 0 after our replaceText. Restore it in the next frame
        // using ChangeSource.remote so _changesSub is not triggered.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final target = offset.clamp(0, controller.document.length - 1);
          controller.updateSelection(
            TextSelection.collapsed(offset: target),
            ChangeSource.remote,
          );
        });
        return;
      }
      offset += op.length ?? 1;
    }
  }
}
