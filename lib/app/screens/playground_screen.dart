import 'package:nota/app/ui_settings_scope.dart';
import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';

/// Manual test screen for verifying app-wide settings.
///
/// Accessible only in non-release builds. Replace [MaterialContext]'s
/// `home: Placeholder()` with `home: const PlaygroundScreen()` to use it.
class PlaygroundScreen extends StatelessWidget {
  const PlaygroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = UiSettingsScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Playground')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.mediumLarge),
        children: [
          _Section(
            title: 'Theme Mode',
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text('Dark'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto),
                  label: Text('System'),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (value) {
                UiSettingsScope.update(
                  context,
                  (s) => s.copyWith(themeMode: value.first),
                );
              },
            ),
          ),
          const SizedBox(height: Spacing.large),
          _Section(
            title: 'Locale',
            child: SegmentedButton<Locale>(
              segments: const [
                ButtonSegment(value: Locale('en'), label: Text('English')),
                ButtonSegment(value: Locale('ru'), label: Text('Русский')),
              ],
              selected: {settings.locale},
              onSelectionChanged: (value) {
                UiSettingsScope.update(
                  context,
                  (s) => s.copyWith(locale: value.first),
                );
              },
            ),
          ),
          const SizedBox(height: Spacing.large),
          _Section(
            title: 'Current UiSettings',
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.mediumLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('themeMode: ${settings.themeMode.name}'),
                    const SizedBox(height: Spacing.small),
                    Text('locale: ${settings.locale.languageCode}'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.large),
          _Section(
            title: 'Localization Demo',
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.mediumLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_l10n(context, 'greeting')),
                    const SizedBox(height: Spacing.small),
                    Text(_l10n(context, 'notes')),
                    const SizedBox(height: Spacing.small),
                    Text(_l10n(context, 'settings')),
                    const SizedBox(height: Spacing.medium),
                    // System widget — changes language automatically
                    ElevatedButton(
                      onPressed: () => showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      ),
                      child: Text(_l10n(context, 'pick_date')),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.large),
          _Section(
            title: 'Design Tokens',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Spacing',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: Spacing.small),
                ..._spacingValues.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.xSmall),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(entry.$1),
                        ),
                        Container(
                          width: entry.$2,
                          height: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: Spacing.small),
                        Text('${entry.$2.toInt()}px'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.medium),
                const Text(
                  'FontSize',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: Spacing.small),
                ..._fontSizeValues.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.xSmall),
                    child: Text(
                      '${entry.$1}: Aa',
                      style: TextStyle(fontSize: entry.$2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: FontSize.medium,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: Spacing.small),
        child,
      ],
    );
  }
}

String _l10n(BuildContext context, String key) {
  final locale = Localizations.localeOf(context).languageCode;
  return _strings[locale]?[key] ?? _strings['en']![key]!;
}

const _strings = {
  'en': {
    'greeting': '👋 Hello, World!',
    'notes': '📝 My Notes',
    'settings': '⚙️ UiSettings',
    'pick_date': 'Pick a date',
  },
  'ru': {
    'greeting': '👋 Привет, Мир!',
    'notes': '📝 Мои заметки',
    'settings': '⚙️ Настройки',
    'pick_date': 'Выбрать дату',
  },
};

const _spacingValues = [
  ('xSmall', Spacing.xSmall),
  ('small', Spacing.small),
  ('medium', Spacing.medium),
  ('mediumLarge', Spacing.mediumLarge),
  ('large', Spacing.large),
  ('xLarge', Spacing.xLarge),
];

const _fontSizeValues = [
  ('small', FontSize.small),
  ('medium', FontSize.medium),
  ('mediumLarge', FontSize.mediumLarge),
  ('large', FontSize.large),
  ('xLarge', FontSize.xLarge),
];
