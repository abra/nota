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
/// word is left alone. Matching ignores case, surrounding punctuation, the
/// Russian ё/е distinction and Arabic diacritics and hamza spellings, all of
/// which recognisers get wrong. Languages written without spaces (Japanese,
/// Chinese) match the phrase as a suffix instead of by words.
final class DictationCommandSet {
  DictationCommandSet({
    required this.languageCode,
    required Map<DictationCommand, List<String>> phrases,
    this.spaceDelimited = true,
  }) : _phrases = phrases,
       _compiled = _compile(phrases, spaceDelimited: spaceDelimited);

  final String languageCode;

  /// False for scripts without word spaces; phrases then match as suffixes.
  final bool spaceDelimited;
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
    if (!spaceDelimited) return _matchSuffix(utterance);
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

  /// Suffix matching for scripts without word spaces: "牛乳、改行。" ends
  /// with the phrase "改行" once trailing punctuation is dropped.
  DictationCommandMatch? _matchSuffix(String utterance) {
    final normalized = _trimTrailingPunctuation(
      _normalizeText(utterance.trim()),
    );
    if (normalized.isEmpty) return null;
    for (final phrase in _compiled) {
      final suffix = phrase.tokens.single;
      if (!normalized.endsWith(suffix)) continue;
      final remainder = _trimTrailingPunctuation(
        normalized.substring(0, normalized.length - suffix.length),
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

  /// Arabic short vowels, tanwin, shadda, sukun, dagger alef and tatweel.
  static final _arabicMarks = RegExp(r'[\u064B-\u0652\u0670\u0640]');
  static final _alefVariants = RegExp('[أإآ]');

  static String _normalizeText(String text) => text
      .toLowerCase()
      .replaceAll('ё', 'е')
      .replaceAll(_arabicMarks, '')
      .replaceAll(_alefVariants, 'ا');

  static String _normalizeWord(String word) =>
      _normalizeText(word).replaceAll(_edgePunctuation, '');

  static String _trimTrailingPunctuation(String text) =>
      text.replaceAll(_trailingPunctuation, '');

  static List<_CompiledPhrase> _compile(
    Map<DictationCommand, List<String>> phrases, {
    required bool spaceDelimited,
  }) {
    final compiled = [
      for (final MapEntry(key: command, value: list) in phrases.entries)
        for (final phrase in list)
          _CompiledPhrase(
            command: command,
            tokens: spaceDelimited
                ? [
                    for (final word in phrase.split(_whitespace))
                      if (_normalizeWord(word).isNotEmpty) _normalizeWord(word),
                  ]
                : [_normalizeText(phrase)],
          ),
    ];
    // Longest first, so "new paragraph" wins over a hypothetical "paragraph"
    // and "音声入力を終了" over "入力終了".
    compiled.sort((a, b) {
      final byTokens = b.tokens.length.compareTo(a.tokens.length);
      if (byTokens != 0) return byTokens;
      return b.tokens.join().length.compareTo(a.tokens.join().length);
    });
    return compiled;
  }
}

final class _CompiledPhrase {
  const _CompiledPhrase({required this.command, required this.tokens});

  final DictationCommand command;
  final List<String> tokens;
}

/// Built-in command sets, one per app language. A language without a set
/// would still dictate, just without spoken commands.
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

  static final de = DictationCommandSet(
    languageCode: 'de',
    phrases: {
      DictationCommand.newLine: [
        'neue Zeile',
        'nächste Zeile',
        'neuer Absatz',
        'neuer Punkt',
        'nächster Punkt',
        'Zeilenumbruch',
      ],
      DictationCommand.undo: [
        'rückgängig',
        'rückgängig machen',
        'das löschen',
        'letztes löschen',
        'Letzten löschen',
      ],
      DictationCommand.stop: [
        'Diktat beenden',
        'Diktat stoppen',
        'Diktat stopp',
        'Aufnahme beenden',
        'Aufnahme stoppen',
      ],
    },
  );

  static final es = DictationCommandSet(
    languageCode: 'es',
    phrases: {
      DictationCommand.newLine: [
        'nueva línea',
        'línea nueva',
        'siguiente línea',
        'nuevo párrafo',
        'nuevo elemento',
        'siguiente elemento',
      ],
      DictationCommand.undo: [
        'deshacer',
        'deshacer eso',
        'borrar eso',
        'borrar lo último',
        'eliminar lo último',
      ],
      DictationCommand.stop: [
        'detener dictado',
        'parar dictado',
        'parar el dictado',
        'terminar dictado',
        'fin del dictado',
      ],
    },
  );

  static final fr = DictationCommandSet(
    languageCode: 'fr',
    phrases: {
      DictationCommand.newLine: [
        'nouvelle ligne',
        'à la ligne',
        'ligne suivante',
        'nouveau paragraphe',
        'nouvel élément',
        'élément suivant',
      ],
      DictationCommand.undo: [
        'annuler',
        'annule ça',
        'efface ça',
        'supprimer le dernier',
        'supprime le dernier',
      ],
      DictationCommand.stop: [
        'arrêter la dictée',
        'arrête la dictée',
        'fin de la dictée',
        'terminer la dictée',
        'stop dictée',
      ],
    },
  );

  static final pt = DictationCommandSet(
    languageCode: 'pt',
    phrases: {
      DictationCommand.newLine: [
        'nova linha',
        'próxima linha',
        'novo parágrafo',
        'novo item',
        'próximo item',
        'quebra de linha',
      ],
      DictationCommand.undo: [
        'desfazer',
        'desfazer isso',
        'apagar isso',
        'apagar o último',
        'remover o último',
      ],
      DictationCommand.stop: [
        'parar ditado',
        'parar o ditado',
        'encerrar ditado',
        'terminar ditado',
        'fim do ditado',
      ],
    },
  );

  static final ja = DictationCommandSet(
    languageCode: 'ja',
    spaceDelimited: false,
    phrases: {
      DictationCommand.newLine: ['改行', '次の行', '新しい行', '次の項目', '新しい項目'],
      DictationCommand.undo: ['元に戻す', '取り消し', '取り消して', '今のを消して', '最後を削除'],
      DictationCommand.stop: ['音声入力終了', '音声入力を終了', '入力終了', '聞き取り終了', 'ストップ'],
    },
  );

  static final zh = DictationCommandSet(
    languageCode: 'zh',
    spaceDelimited: false,
    phrases: {
      DictationCommand.newLine: ['换行', '新行', '下一行', '新段落', '下一项', '新的一项'],
      DictationCommand.undo: ['撤销', '撤消', '删除刚才的', '删掉刚才的', '删除上一条'],
      DictationCommand.stop: ['停止听写', '结束听写', '停止录音', '听写结束', '停止语音输入'],
    },
  );

  // Hindi speakers often mix in English, so the English phrases count too.
  static final hi = DictationCommandSet(
    languageCode: 'hi',
    phrases: {
      DictationCommand.newLine: [
        'नई लाइन',
        'नई पंक्ति',
        'अगली लाइन',
        'नया पैराग्राफ',
        'नया आइटम',
        'अगला आइटम',
        'new line',
        'next line',
      ],
      DictationCommand.undo: [
        'पूर्ववत करें',
        'वापस लो',
        'आखिरी हटाओ',
        'पिछला हटाओ',
        'इसे हटाओ',
        'undo',
      ],
      DictationCommand.stop: [
        'डिक्टेशन बंद करो',
        'डिक्टेशन रोको',
        'रिकॉर्डिंग बंद करो',
        'बोलना बंद',
        'stop dictation',
      ],
    },
  );

  static final ar = DictationCommandSet(
    languageCode: 'ar',
    phrases: {
      DictationCommand.newLine: [
        'سطر جديد',
        'السطر التالي',
        'فقرة جديدة',
        'عنصر جديد',
        'العنصر التالي',
      ],
      DictationCommand.undo: [
        'تراجع',
        'تراجع عن ذلك',
        'احذف ذلك',
        'احذف الأخير',
        'امسح الأخير',
      ],
      DictationCommand.stop: [
        'إيقاف الإملاء',
        'أوقف الإملاء',
        'إنهاء الإملاء',
        'توقف عن الإملاء',
        'انه الإملاء',
      ],
    },
  );

  /// Every built-in set, one per app language.
  static final all = [en, ru, de, es, fr, pt, ja, zh, hi, ar];

  static final _byLanguage = {for (final set in all) set.languageCode: set};

  /// The command set for [languageCode], or `null` when none exists.
  static DictationCommandSet? forLanguage(String languageCode) =>
      _byLanguage[languageCode.toLowerCase()];
}
