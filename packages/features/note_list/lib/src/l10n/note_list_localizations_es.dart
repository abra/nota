// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class NoteListLocalizationsEs extends NoteListLocalizations {
  NoteListLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String selected(int count) {
    return '$count seleccionados';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas eliminadas',
      one: 'Nota eliminada',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'No hay notas';

  @override
  String get searchHint => 'Buscar';

  @override
  String get noteDeleteFailed => 'Error al eliminar la nota';

  @override
  String get noteUpdateFailed => 'Error al actualizar la nota';

  @override
  String get loadFailed => 'Error al cargar notas';

  @override
  String get retry => 'Reintentar';

  @override
  String get pinned => 'Fijadas';

  @override
  String get others => 'Otras';

  @override
  String get yesterday => 'Ayer';

  @override
  String get noResults => 'No se encontró nada';

  @override
  String get noResultsHint => 'Prueba con otra búsqueda';

  @override
  String get emptyStateHint => 'Toca + para crear tu primera nota';

  @override
  String get undo => 'Deshacer';

  @override
  String get addNote => 'Nueva nota';

  @override
  String get menu => 'Menú';

  @override
  String get pin => 'Fijar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get noteRestoreFailed => 'No se pudo restaurar la nota';
}
