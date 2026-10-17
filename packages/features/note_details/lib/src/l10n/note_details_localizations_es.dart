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

  @override
  String get dictate => 'Dictar';

  @override
  String get dictationModeText => 'Texto';

  @override
  String get dictationModeList => 'Lista';

  @override
  String get dictationModeChecklist => 'Lista de tareas';

  @override
  String get dictationStarting => 'Iniciando…';

  @override
  String get dictationListening => 'Escuchando…';

  @override
  String get dictationPaused => 'En pausa. Toca el micrófono para continuar';

  @override
  String get dictationHintList => 'Escuchando… haz una pausa entre elementos';

  @override
  String dictationHintNewLine(String phrase) {
    return 'Escuchando… di «$phrase» para una nueva línea';
  }

  @override
  String get dictationPause => 'Pausar dictado';

  @override
  String get dictationResume => 'Reanudar dictado';

  @override
  String get dictationPermissionDenied =>
      'Permite el acceso al micrófono y al reconocimiento de voz en Ajustes';

  @override
  String get dictationUnavailable =>
      'El reconocimiento de voz no está disponible en este dispositivo';

  @override
  String get dictationLanguageUnsupported =>
      'El reconocimiento de voz no está disponible para este idioma';

  @override
  String get dictationNetworkError =>
      'El reconocimiento de voz necesita conexión de red';

  @override
  String get dictationFailed => 'El dictado se detuvo por un error';
}
