import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared/shared.dart';

import 'note_card.dart';

/// Two-column masonry grid of [NoteCard]s. Returns a sliver.
class NoteSliverGrid extends StatelessWidget {
  const NoteSliverGrid({
    super.key,
    required this.notes,
    required this.selectedIds,
    required this.isSelectionMode,
    required this.dateLabelFor,
    this.onNotePressed,
    this.onNoteLongPressed,
  });

  final List<Note> notes;
  final Set<String> selectedIds;
  final bool isSelectionMode;
  final String Function(Note) dateLabelFor;
  final ValueChanged<Note>? onNotePressed;
  final ValueChanged<String>? onNoteLongPressed;

  @override
  Widget build(BuildContext context) {
    return SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: Spacing.medium,
      crossAxisSpacing: Spacing.medium,
      childCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          key: ValueKey(note.id),
          note: note,
          dateLabel: dateLabelFor(note),
          isSelected: selectedIds.contains(note.id),
          onPressed: isSelectionMode
              ? () => onNoteLongPressed?.call(note.id)
              : onNotePressed == null
              ? null
              : () => onNotePressed!(note),
          onLongPress: isSelectionMode
              ? null
              : () => onNoteLongPressed?.call(note.id),
        );
      },
    );
  }
}
