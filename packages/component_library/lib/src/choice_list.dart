import 'package:flutter/material.dart';

import 'settings_group.dart';
import 'theme/icon_size.dart';
import 'theme/spacing.dart';

/// One selectable entry of a [ChoiceList].
final class Choice<T> {
  const Choice({required this.value, required this.label});

  final T value;
  final String label;
}

/// A run of [Choice]s drawn as one rounded group, with an optional heading.
final class ChoiceSection<T> {
  const ChoiceSection({required this.choices, this.title});

  final String? title;
  final List<Choice<T>> choices;
}

/// Single-choice list in the style of [SettingsGroup]: each section is a
/// rounded group with hairlines between its rows and a checkmark on the
/// [selected] value.
///
/// Rows are built lazily, so a list of a hundred recogniser languages costs
/// no more than the rows on screen. The list is as tall as its content up to
/// [maxHeight] and scrolls beyond that.
class ChoiceList<T> extends StatelessWidget {
  const ChoiceList({
    required this.sections,
    required this.selected,
    required this.onSelected,
    this.maxHeight = 320,
    super.key,
  });

  final List<ChoiceSection<T>> sections;
  final T selected;
  final ValueChanged<T> onSelected;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final items = _flatten(sections);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        itemBuilder: (context, index) => switch (items[index]) {
          _Heading<T>(:final title, :final isFirst) => _ChoiceHeading(
            title: title,
            isFirst: isFirst,
          ),
          _Gap<T>() => const SizedBox(height: Spacing.medium),
          _Row<T>(:final choice, :final isFirst, :final isLast) => _ChoiceRow(
            label: choice.label,
            isSelected: choice.value == selected,
            isFirst: isFirst,
            isLast: isLast,
            onTap: () => onSelected(choice.value),
          ),
        },
      ),
    );
  }

  static List<_Item<T>> _flatten<T>(List<ChoiceSection<T>> sections) {
    final items = <_Item<T>>[];
    for (final section in sections) {
      if (section.choices.isEmpty) continue;
      final isFirst = items.isEmpty;
      if (section.title case final title?) {
        items.add(_Heading(title, isFirst: isFirst));
      } else if (!isFirst) {
        items.add(_Gap());
      }
      final last = section.choices.length - 1;
      for (var i = 0; i <= last; i++) {
        items.add(
          _Row(section.choices[i], isFirst: i == 0, isLast: i == last),
        );
      }
    }
    return items;
  }
}

sealed class _Item<T> {
  const _Item();
}

final class _Heading<T> extends _Item<T> {
  const _Heading(this.title, {required this.isFirst});

  final String title;
  final bool isFirst;
}

final class _Gap<T> extends _Item<T> {
  const _Gap();
}

final class _Row<T> extends _Item<T> {
  const _Row(this.choice, {required this.isFirst, required this.isLast});

  final Choice<T> choice;
  final bool isFirst;
  final bool isLast;
}

class _ChoiceHeading extends StatelessWidget {
  const _ChoiceHeading({required this.title, required this.isFirst});

  final String title;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.mediumLarge,
        isFirst ? 0 : Spacing.mediumLarge,
        Spacing.mediumLarge,
        Spacing.small,
      ),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// One row, drawing its own slice of the group: rounded on the outer edges,
/// a hairline above every row but the first.
class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: SettingsGroup.colorOf(theme),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? SettingsGroup.radius : Radius.zero,
          bottom: isLast ? SettingsGroup.radius : Radius.zero,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(
          top: isFirst ? Spacing.xSmall : 0,
          bottom: isLast ? Spacing.xSmall : 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isFirst) SettingsGroup.divider(colorScheme),
            // Merged so the row reads as one selectable radio-like entry.
            MergeSemantics(
              child: Semantics(
                selected: isSelected,
                inMutuallyExclusiveGroup: true,
                child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Spacing.mediumLarge,
                  ),
                  title: Text(
                    label,
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
                  onTap: onTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
