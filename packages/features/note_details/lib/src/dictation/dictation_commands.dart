/// Spoken commands recognised at the end of an utterance.
enum DictationCommand {
  /// Start a new line (a new item in list modes).
  newLine,

  /// Revert the last edit.
  undo,

  /// Pause dictation.
  stop,
}

/// A command found at the end of an utterance, with the text before it.
final class DictationCommandMatch {
  const DictationCommandMatch({required this.command, required this.remainder});

  final DictationCommand command;

  /// The utterance without the command phrase, trimmed. Empty when the
  /// utterance was only the command.
  final String remainder;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DictationCommandMatch &&
          command == other.command &&
          remainder == other.remainder;

  @override
  int get hashCode => Object.hash(command, remainder);

  @override
  String toString() => 'DictationCommandMatch($command, "$remainder")';
}

/// Voice commands for one language.
///
/// Commands are only matched at the end of an utterance ("milk, new line"),
/// never in the middle, so ordinary speech that happens to contain a command
/// word is left alone. Matching ignores case, surrounding punctuation and
/// the Russian ё/е distinction, all of which recognisers get wrong.
final class DictationCommandSet {
  DictationCommandSet({
    required this.languageCode,
    required Map<DictationCommand, List<String>> phrases,
  }) : _phrases = phrases,
       _compiled = _compile(phrases);

  final String languageCode;
  final Map<DictationCommand, List<String>> _phrases;

  /// Phrases tokenised once, longest first so "new paragraph" wins over a
  /// hypothetical "paragraph".
  final List<_CompiledPhrase> _compiled;

  /// Every phrase, for recogniser hints.
  List<String> get allPhrases => [for (final list in _phrases.values) ...list];

  /// The phrase shown to users for [command].
  String primaryPhrase(DictationCommand command) => _phrases[command]!.first;

  /// Finds a command at the end of [utterance].
  DictationCommandMatch? match(String utterance) {
    final words = utterance.trim().split(_whitespace);
    if (words.length == 1 && words.first.isEmpty) return null;

    // Keep only words that still have letters after normalisation; a lone
    // punctuation token would otherwise shift the comparison.
    final normalized = <String>[];
    final kept = <String>[];
    for (final word in words) {
      final n = _normalizeWord(word);
      if (n.isEmpty) continue;
      normalized.add(n);
      kept.add(word);
    }

    for (final phrase in _compiled) {
      final tokens = phrase.tokens;
      if (tokens.length > normalized.length) continue;
      final offset = normalized.length - tokens.length;
      var matches = true;
      for (var i = 0; i < tokens.length; i++) {
        if (normalized[offset + i] != tokens[i]) {
          matches = false;
          break;
        }
      }
      if (!matches) continue;
      final remainder = _trimTrailingPunctuation(
        kept.sublist(0, offset).join(' '),
      );
      return DictationCommandMatch(
        command: phrase.command,
        remainder: remainder,
      );
    }
    return null;
  }

  static final _whitespace = RegExp(r'\s+');
  static final _edgePunctuation = RegExp(
    r'^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$',
    unicode: true,
  );
  static final _trailingPunctuation = RegExp(r'[\s\p{P}]+$', unicode: true);

  static String _normalizeWord(String word) =>
      word.toLowerCase().replaceAll('ё', 'е').replaceAll(_edgePunctuation, '');

  static String _trimTrailingPunctuation(String text) =>
      text.replaceAll(_trailingPunctuation, '');

  static List<_CompiledPhrase> _compile(
    Map<DictationCommand, List<String>> phrases,
  ) {
    final compiled = [
      for (final MapEntry(key: command, value: list) in phrases.entries)
        for (final phrase in list)
          _CompiledPhrase(
            command: command,
            tokens: [
              for (final word in phrase.split(_whitespace))
                if (_normalizeWord(word).isNotEmpty) _normalizeWord(word),
            ],
          ),
    ];
    compiled.sort((a, b) => b.tokens.length.compareTo(a.tokens.length));
    return compiled;
  }
}

final class _CompiledPhrase {
  const _CompiledPhrase({required this.command, required this.tokens});

  final DictationCommand command;
  final List<String> tokens;
}

/// Built-in command sets. Languages without one still dictate; they just
/// rely on the panel buttons instead of spoken commands.
abstract final class DictationCommands {
  static final en = DictationCommandSet(
    languageCode: 'en',
    phrases: {
      DictationCommand.newLine: [
        'new line',
        'newline',
        'next line',
        'new paragraph',
        'new item',
        'next item',
      ],
      DictationCommand.undo: [
        'undo',
        'undo that',
        'scratch that',
        'delete that',
        'delete last',
        'remove last',
      ],
      // Two words on purpose: "stop" alone ends too many ordinary sentences.
      DictationCommand.stop: [
        'stop dictation',
        'stop dictating',
        'stop listening',
        'stop recording',
        'end dictation',
      ],
    },
  );

  static final ru = DictationCommandSet(
    languageCode: 'ru',
    phrases: {
      DictationCommand.newLine: [
        'новая строка',
        'с новой строки',
        'новый пункт',
        'следующий пункт',
        'новый абзац',
      ],
      DictationCommand.undo: [
        'отмена',
        'отменить',
        'удалить последнее',
        'удали последнее',
        'убрать последнее',
      ],
      DictationCommand.stop: [
        'стоп',
        'стоп диктовка',
        'закончить диктовку',
        'хватит диктовать',
      ],
    },
  );

  static final _byLanguage = {
    for (final set in [en, ru]) set.languageCode: set,
  };

  /// The command set for [languageCode], or `null` when none exists.
  static DictationCommandSet? forLanguage(String languageCode) =>
      _byLanguage[languageCode.toLowerCase()];
}
