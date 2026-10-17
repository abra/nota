import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/shared.dart';

import 'note_card.dart';

/// Single-column list of [NoteCard]s with swipe-to-delete. Returns a sliver.
class NoteSliverList extends StatelessWidget {
  const NoteSliverList({
    super.key,
    required this.notes,
    required this.density,
    required this.selectedIds,
    required this.isSelectionMode,
    required this.dateLabelFor,
    this.onNotePressed,
    this.onNoteDeleted,
    this.onNoteLongPressed,
  });

  final List<Note> notes;
  final NoteListDensity density;
  final Set<String> selectedIds;
  final bool isSelectionMode;
  final String Function(Note) dateLabelFor;
  final ValueChanged<Note>? onNotePressed;
  final ValueChanged<String>? onNoteDeleted;
  final ValueChanged<String>? onNoteLongPressed;

  static const _radius = BorderRadius.all(
    Radius.circular(AppRadius.mediumLarge),
  );

  // A note without a title gets one extra preview line so its card height
  // roughly matches a titled note at the same density.
  int _contentMaxLines(Note note) {
    final extra = note.title == null ? 1 : 0;
    return switch (density) {
      NoteListDensity.twoLines => 1 + extra,
      NoteListDensity.threeLines => 2 + extra,
      NoteListDensity.fourLines => 3 + extra,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverList.separated(
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: Spacing.small),
      itemBuilder: (context, index) {
        final note = notes[index];
        final card = NoteCard(
          key: ValueKey(note.id),
          note: note,
          layout: NoteCardLayout.list,
          dateLabel: dateLabelFor(note),
          isSelected: selectedIds.contains(note.id),
          titleMaxLines: 1,
          contentMaxLines: _contentMaxLines(note),
          onPressed: isSelectionMode
              ? () => onNoteLongPressed?.call(note.id)
              : onNotePressed == null
              ? null
              : () => onNotePressed!(note),
          onLongPress: isSelectionMode
              ? null
              : () => onNoteLongPressed?.call(note.id),
        );

        if (isSelectionMode || onNoteDeleted == null) return card;

        return Dismissible(
          key: ValueKey('dismiss-${note.id}'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            HapticFeedback.mediumImpact();
            onNoteDeleted!(note.id);
          },
          background: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.error,
              borderRadius: _radius,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.large,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: colorScheme.onError,
                ),
              ),
            ),
          ),
          child: card,
        );
      },
    );
  }
}
