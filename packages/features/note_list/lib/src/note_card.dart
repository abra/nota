import 'dart:io';

import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

enum NoteCardLayout {
  /// Vertical card: image on top, then title, preview and footer.
  grid,

  /// Horizontal row: thumbnail on the left, text on the right.
  list,
}

/// A single note in the list or grid.
///
/// Colours come from the note itself; uncoloured notes use the card theme.
/// Selection is drawn as a foreground border so the layout never shifts.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    this.layout = NoteCardLayout.grid,
    this.dateLabel,
    this.onPressed,
    this.onLongPress,
    this.isSelected = false,
    this.contentMaxLines = 8,
    this.titleMaxLines = 2,
  });

  final Note note;
  final NoteCardLayout layout;

  /// Pre-formatted timestamp shown in the footer; hidden when null.
  final String? dateLabel;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final int contentMaxLines;
  final int titleMaxLines;

  static const _radius = BorderRadius.all(
    Radius.circular(AppRadius.mediumLarge),
  );
  static const _imageRadius = BorderRadius.all(
    Radius.circular(AppRadius.small),
  );
  static const _gridImageHeight = 120.0;
  static const _listThumbSize = 56.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;
    final hasColor = note.color != NoteColor.none;

    final background = hasColor
        ? note.color.forBrightness(brightness)
        : theme.cardTheme.color ?? colorScheme.surfaceContainerLow;
    final foreground = hasColor
        ? note.color.onColorFor(brightness)
        : colorScheme.onSurface;
    final muted = foreground.withValues(alpha: 0.55);

    final borderColor = isSelected
        ? colorScheme.primary
        : isDark && !hasColor
        ? colorScheme.outlineVariant.withValues(alpha: 0.7)
        : Colors.transparent;

    final titleStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: foreground,
      height: 1.3,
    );
    final contentStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w400,
      color: foreground.withValues(alpha: 0.82),
      height: 1.4,
    );
    final footerStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w400,
      color: muted,
    );

    final preview = _NotePreview.of(note);
    final image = preview.firstImagePath;

    final body = _CardBody(
      note: note,
      preview: preview,
      titleStyle: titleStyle,
      contentStyle: contentStyle,
      footerStyle: footerStyle,
      titleMaxLines: titleMaxLines,
      contentMaxLines: contentMaxLines,
      dateLabel: dateLabel,
      pinColor: muted,
    );

    final Widget content = switch (layout) {
      NoteCardLayout.grid => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (image != null)
            _NoteImage(
              path: image,
              height: _gridImageHeight,
              width: double.infinity,
            ),
          Padding(
            padding: const EdgeInsets.all(Spacing.mediumLarge),
            child: body,
          ),
        ],
      ),
      NoteCardLayout.list => Padding(
        padding: const EdgeInsets.all(Spacing.mediumLarge),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null) ...[
              ClipRRect(
                borderRadius: _imageRadius,
                child: _NoteImage(
                  path: image,
                  width: _listThumbSize,
                  height: _listThumbSize,
                ),
              ),
              const SizedBox(width: Spacing.medium),
            ],
            Expanded(child: body),
          ],
        ),
      ),
    };

    return Semantics(
      selected: isSelected,
      button: onPressed != null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(color: background, borderRadius: _radius),
        foregroundDecoration: BoxDecoration(
          borderRadius: _radius,
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: ClipRRect(
          borderRadius: _radius,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              onLongPress: onLongPress,
              child: Stack(
                children: [
                  content,
                  if (isSelected)
                    Positioned(
                      top: Spacing.small,
                      right: Spacing.small,
                      child: _SelectedBadge(color: colorScheme.primary),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Facts about a note's content that every card needs, decoded from Delta
/// JSON once per [Note] instance. Notes are immutable and reused across state
/// copies, so an identity-keyed [Expando] is a safe, self-cleaning cache.
class _NotePreview {
  const _NotePreview._({
    required this.ops,
    required this.firstImagePath,
    required this.hasText,
  });

  /// Decoded ops, or null when the content is legacy plain text.
  final List<dynamic>? ops;
  final String? firstImagePath;
  final bool hasText;

  static final _cache = Expando<_NotePreview>('note preview');

  factory _NotePreview.of(Note note) =>
      _cache[note] ??= _NotePreview._parse(note.content);

  factory _NotePreview._parse(String content) {
    final ops = DeltaUtils.extractOps(content);
    if (ops == null) {
      return _NotePreview._(
        ops: null,
        firstImagePath: null,
        hasText: content.trim().isNotEmpty,
      );
    }
    return _NotePreview._(
      ops: ops,
      firstImagePath: DeltaUtils.firstImagePathOf(ops),
      hasText: DeltaUtils.plainTextOf(ops).trim().isNotEmpty,
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.note,
    required this.preview,
    required this.titleStyle,
    required this.contentStyle,
    required this.footerStyle,
    required this.titleMaxLines,
    required this.contentMaxLines,
    required this.dateLabel,
    required this.pinColor,
  });

  final Note note;
  final _NotePreview preview;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final TextStyle? footerStyle;
  final int titleMaxLines;
  final int contentMaxLines;
  final String? dateLabel;
  final Color pinColor;

  @override
  Widget build(BuildContext context) {
    final title = note.title;
    final hasText = preview.hasText;
    final showFooter = dateLabel != null || note.isPinned;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Text(
            title,
            style: titleStyle,
            maxLines: titleMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        if (title != null && hasText) const SizedBox(height: Spacing.xSmall),
        if (hasText)
          Text.rich(
            TextSpan(
              style: contentStyle,
              children: _buildContentSpans(
                preview.ops,
                note.content,
                contentStyle!,
              ),
            ),
            maxLines: contentMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        if (showFooter) ...[
          const SizedBox(height: Spacing.medium),
          Row(
            children: [
              if (dateLabel != null)
                Expanded(
                  child: Text(
                    dateLabel!,
                    style: footerStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const Spacer(),
              if (note.isPinned)
                Icon(
                  Icons.push_pin_rounded,
                  size: IconSize.xSmall,
                  color: pinColor,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _NoteImage extends StatelessWidget {
  const _NoteImage({
    required this.path,
    required this.width,
    required this.height,
  });

  final String path;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}

class _SelectedBadge extends StatelessWidget {
  const _SelectedBadge({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xSmall),
        child: Icon(
          Icons.check_rounded,
          size: IconSize.xSmall,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}

/// Renders decoded Delta [ops] as rich preview spans: list markers, checkbox
/// glyphs and inline styles. Plain-text content ([ops] == null) is returned
/// as a single span.
List<InlineSpan> _buildContentSpans(
  List<dynamic>? ops,
  String content,
  TextStyle baseStyle,
) {
  if (ops == null) return [TextSpan(text: content, style: baseStyle)];

  final result = <InlineSpan>[];
  final pendingLine = <InlineSpan>[];
  int orderedCounter = 0;
  bool firstLine = true;

  void flushLine(Map<dynamic, dynamic>? blockAttrs) {
    final listType = blockAttrs?['list'] as String?;
    if (!firstLine) result.add(const TextSpan(text: '\n'));
    firstLine = false;
    String prefix = '';
    switch (listType) {
      case 'bullet':
        prefix = '• ';
        orderedCounter = 0;
      case 'ordered':
        orderedCounter++;
        prefix = '$orderedCounter. ';
      case 'checked':
      case 'unchecked':
        result.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: Spacing.xSmall),
              child: Icon(
                listType == 'checked'
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: (baseStyle.fontSize ?? 12) + 2,
                color: baseStyle.color,
              ),
            ),
          ),
        );
        orderedCounter = 0;
        result.addAll(pendingLine);
        pendingLine.clear();
        return;
      default:
        orderedCounter = 0;
    }
    if (prefix.isNotEmpty) {
      result.add(TextSpan(text: prefix, style: baseStyle));
    }
    result.addAll(pendingLine);
    pendingLine.clear();
  }

  for (final op in ops) {
    if (op is! Map) continue;
    final insert = op['insert'];
    final attrs = op['attributes'] as Map<dynamic, dynamic>?;
    if (insert is! String) continue; // skip image embeds
    if (insert == '\n') {
      flushLine(attrs);
    } else {
      final lines = insert.split('\n');
      for (int i = 0; i < lines.length; i++) {
        final part = lines[i];
        if (part.isNotEmpty) {
          pendingLine.add(
            TextSpan(text: part, style: _applyInlineStyle(baseStyle, attrs)),
          );
        }
        if (i < lines.length - 1) flushLine(null);
      }
    }
  }

  if (pendingLine.isNotEmpty) flushLine(null);
  return result;
}

TextStyle _applyInlineStyle(TextStyle base, Map<dynamic, dynamic>? attrs) {
  if (attrs == null) return base;
  var style = base;
  if (attrs['bold'] == true) {
    style = style.copyWith(fontWeight: FontWeight.w600);
  }
  if (attrs['italic'] == true) {
    style = style.copyWith(fontStyle: FontStyle.italic);
  }
  if (attrs['underline'] == true) {
    style = style.copyWith(decoration: TextDecoration.underline);
  }
  if (attrs['strike'] == true) {
    style = style.copyWith(decoration: TextDecoration.lineThrough);
  }
  return style;
}
