// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class NoteDetailsLocalizationsEs extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get newNote => 'Nueva nota';

  @override
  String get editNote => 'Editar nota';

  @override
  String get titleHint => 'Título';

  @override
  String get contentHint => 'Empieza a escribir...';

  @override
  String get noteNotFound => 'Nota no encontrada';

  @override
  String get noteLoadFailed => 'Error al cargar la nota';

  @override
  String get noteSaveFailed => 'Error al guardar la nota';

  @override
  String get noteColor => 'Color de nota';

  @override
  String get imageInsertFailed => 'Error al insertar la imagen';

  @override
  String get deleteNote => 'Eliminar nota';

  @override
  String get pinNote => 'Fijar';

  @override
  String get unpinNote => 'Desfijar';

  @override
  String editedAt(String date) {
    return 'Editado $date';
  }

  @override
  String get back => 'Atrás';

  @override
  String get moreActions => 'Más';

  @override
  String get formatting => 'Formato';

  @override
  String get insertImage => 'Insertar imagen';

  @override
  String get undo => 'Deshacer';

  @override
  String get redo => 'Rehacer';

  @override
  String get newLine => 'Nueva línea';
}
