// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class NoteDetailsLocalizationsRu extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get newNote => 'Новая заметка';

  @override
  String get editNote => 'Редактировать';

  @override
  String get titleHint => 'Заголовок';

  @override
  String get contentHint => 'Начните писать...';

  @override
  String get noteNotFound => 'Заметка не найдена';

  @override
  String get noteLoadFailed => 'Не удалось загрузить заметку';

  @override
  String get noteSaveFailed => 'Не удалось сохранить заметку';

  @override
  String get noteColor => 'Цвет заметки';

  @override
  String get imageInsertFailed => 'Не удалось вставить изображение';

  @override
  String get deleteNote => 'Удалить заметку';

  @override
  String get pinNote => 'Закрепить';

  @override
  String get unpinNote => 'Открепить';

  @override
  String editedAt(String date) {
    return 'Изменено $date';
  }

  @override
  String get back => 'Назад';

  @override
  String get moreActions => 'Ещё';

  @override
  String get formatting => 'Форматирование';

  @override
  String get insertImage => 'Вставить изображение';

  @override
  String get undo => 'Отменить';

  @override
  String get redo => 'Повторить';

  @override
  String get newLine => 'Новая строка';
}
