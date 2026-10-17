part of 'note_details_screen.dart';

/// Horizontal strip of colour swatches shown in the secondary toolbar panel.
class _InlineColorPanel extends StatelessWidget {
  const _InlineColorPanel({
    required this.selected,
    required this.onSelected,
  });

  final NoteColor selected;
  final ValueChanged<NoteColor> onSelected;

  static const _swatchSize = 32.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    return FloatingPanel(
      child: SizedBox(
        height: FloatingBar.controlSize,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xSmall),
          itemCount: NoteColor.values.length,
          separatorBuilder: (_, _) => const SizedBox(width: Spacing.small),
          itemBuilder: (context, index) {
            final color = NoteColor.values[index];
            final isSelected = color == selected;
            final isNone = color == NoteColor.none;
            final fill = isNone
                ? colorScheme.surfaceContainerHigh
                : color.forBrightness(brightness);
            final check = isNone
                ? colorScheme.onSurfaceVariant
                : color.onColorFor(brightness);
            return Center(
              child: Semantics(
                button: true,
                selected: isSelected,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onSelected(color),
                  child: SizedBox.square(
                    dimension: FloatingBar.controlSize,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: _swatchSize,
                        height: _swatchSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: fill,
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(
                                    alpha: isNone ? 0.2 : 0.1,
                                  ),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                size: IconSize.small,
                                color: check,
                              )
                            : isNone
                            ? Icon(
                                Icons.block,
                                size: IconSize.xSmall,
                                color: colorScheme.onSurfaceVariant,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
