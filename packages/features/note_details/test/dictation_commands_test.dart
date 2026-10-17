import 'package:flutter_test/flutter_test.dart';
import 'package:note_details/src/dictation/dictation_commands.dart';

void main() {
  group('DictationCommands.forLanguage', () {
    test('returns the built-in sets regardless of case', () {
      expect(DictationCommands.forLanguage('en'), same(DictationCommands.en));
      expect(DictationCommands.forLanguage('RU'), same(DictationCommands.ru));
    });

    test('returns null for languages without commands', () {
      expect(DictationCommands.forLanguage('xx'), isNull);
    });

    test('covers every app language', () {
      final codes = DictationCommands.all.map((s) => s.languageCode);
      expect(
        codes,
        containsAll([
          'en',
          'ru',
          'de',
          'es',
          'fr',
          'pt',
          'ja',
          'zh',
          'hi',
          'ar',
        ]),
      );
    });
  });

  group('every built-in set', () {
    for (final set in DictationCommands.all) {
      test('${set.languageCode}: matches each primary phrase on its own', () {
        for (final command in DictationCommand.values) {
          final phrase = set.primaryPhrase(command);
          expect(
            set.match(phrase.toUpperCase()),
            DictationCommandMatch(command: command, remainder: ''),
            reason: '${set.languageCode} "$phrase"',
          );
        }
      });

      test('${set.languageCode}: keeps the words before the command', () {
        final phrase = set.primaryPhrase(DictationCommand.newLine);
        final text = set.spaceDelimited ? 'Abc 123' : '牛乳';
        final joiner = set.spaceDelimited ? ', ' : '、';
        expect(
          set.match('$text$joiner$phrase.'),
          DictationCommandMatch(
            command: DictationCommand.newLine,
            remainder: set.spaceDelimited ? 'Abc 123' : '牛乳',
          ),
        );
      });
    }
  });

  group('scripts without spaces', () {
    test('match the phrase as a suffix and strip punctuation', () {
      expect(
        DictationCommands.ja.match('牛乳、改行。'),
        const DictationCommandMatch(
          command: DictationCommand.newLine,
          remainder: '牛乳',
        ),
      );
      expect(
        DictationCommands.zh.match('牛奶换行'),
        const DictationCommandMatch(
          command: DictationCommand.newLine,
          remainder: '牛奶',
        ),
      );
    });

    test('prefer the longest phrase', () {
      expect(
        DictationCommands.ja.match('音声入力を終了')!.command,
        DictationCommand.stop,
      );
    });

    test('do not match a phrase in the middle', () {
      expect(DictationCommands.ja.match('改行して牛乳'), isNull);
    });
  });

  group('Arabic normalisation', () {
    test('ignores diacritics and hamza spellings', () {
      expect(
        DictationCommands.ar.match('حليب تَرَاجُع')!.command,
        DictationCommand.undo,
      );
      expect(
        DictationCommands.ar.match('اوقف الاملاء')!.command,
        DictationCommand.stop,
      );
      expect(
        DictationCommands.ar.match('أوقف الإملاء')!.command,
        DictationCommand.stop,
      );
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
