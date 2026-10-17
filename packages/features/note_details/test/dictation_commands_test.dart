import 'package:flutter_test/flutter_test.dart';
import 'package:note_details/src/dictation/dictation_commands.dart';

void main() {
  group('DictationCommands.forLanguage', () {
    test('returns the built-in sets regardless of case', () {
      expect(DictationCommands.forLanguage('en'), same(DictationCommands.en));
      expect(DictationCommands.forLanguage('RU'), same(DictationCommands.ru));
    });

    test('returns null for languages without commands', () {
      expect(DictationCommands.forLanguage('de'), isNull);
    });
  });

  group('DictationCommandSet.match', () {
    final en = DictationCommands.en;
    final ru = DictationCommands.ru;

    test('matches an utterance that is only the command', () {
      expect(
        en.match('New line'),
        const DictationCommandMatch(
          command: DictationCommand.newLine,
          remainder: '',
        ),
      );
    });

    test('matches a command at the end and keeps the text before it', () {
      expect(
        en.match('Buy oat milk, new line.'),
        const DictationCommandMatch(
          command: DictationCommand.newLine,
          remainder: 'Buy oat milk',
        ),
      );
    });

    test('ignores case, punctuation and the ё/е spelling', () {
      expect(
        ru.match('Молоко. Новая строка!'),
        const DictationCommandMatch(
          command: DictationCommand.newLine,
          remainder: 'Молоко',
        ),
      );
      expect(
        ru.match('хлеб удалить последнее'),
        const DictationCommandMatch(
          command: DictationCommand.undo,
          remainder: 'хлеб',
        ),
      );
      expect(
        ru.match('всё, стоп'),
        const DictationCommandMatch(
          command: DictationCommand.stop,
          remainder: 'всё',
        ),
      );
    });

    test('does not match a command in the middle of the utterance', () {
      expect(en.match('new line is what I said next'), isNull);
      expect(ru.match('отмена не нужна сегодня'), isNull);
    });

    test('does not match a partial phrase', () {
      expect(
        en.match('I need to stop'),
        isNull,
        reason: 'stop alone is a word',
      );
      expect(en.match('the paragraph'), isNull);
    });

    test('prefers the longest phrase', () {
      expect(
        en.match('groceries undo that'),
        const DictationCommandMatch(
          command: DictationCommand.undo,
          remainder: 'groceries',
        ),
      );
    });

    test('tolerates stray punctuation tokens', () {
      expect(
        en.match('Call mum - new line'),
        const DictationCommandMatch(
          command: DictationCommand.newLine,
          remainder: 'Call mum',
        ),
      );
    });

    test('returns null for empty input', () {
      expect(en.match(''), isNull);
      expect(en.match('   '), isNull);
    });

    test('exposes the primary phrase and all phrases for hints', () {
      expect(en.primaryPhrase(DictationCommand.newLine), 'new line');
      expect(ru.primaryPhrase(DictationCommand.newLine), 'новая строка');
      expect(
        en.allPhrases,
        containsAll(['new line', 'undo', 'stop dictation']),
      );
    });
  });
}
