// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class NoteListLocalizationsRu extends NoteListLocalizations {
  NoteListLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String selected(int count) {
    return '$count выбрано';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заметки удалены',
      one: 'Заметка удалена',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'Нет заметок';

  @override
  String get searchHint => 'Поиск';

  @override
  String get noteDeleteFailed => 'Не удалось удалить заметку';

  @override
  String get noteUpdateFailed => 'Не удалось обновить заметку';

  @override
  String get loadFailed => 'Не удалось загрузить заметки';

  @override
  String get retry => 'Повторить';

  @override
  String get pinned => 'Закреплённые';

  @override
  String get others => 'Остальные';

  @override
  String get yesterday => 'Вчера';

  @override
  String get noResults => 'Ничего не найдено';

  @override
  String get noResultsHint => 'Попробуйте другой запрос';

  @override
  String get emptyStateHint => 'Нажмите +, чтобы создать первую заметку';

  @override
  String get undo => 'Отменить';

  @override
  String get addNote => 'Новая заметка';

  @override
  String get menu => 'Меню';

  @override
  String get pin => 'Закрепить';

  @override
  String get delete => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String get noteRestoreFailed => 'Не удалось восстановить заметку';
}
