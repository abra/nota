// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class NoteDetailsLocalizationsPt extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get newNote => 'Nova nota';

  @override
  String get editNote => 'Editar nota';

  @override
  String get titleHint => 'Título';

  @override
  String get contentHint => 'Comece a escrever...';

  @override
  String get noteNotFound => 'Nota não encontrada';

  @override
  String get noteLoadFailed => 'Falha ao carregar nota';

  @override
  String get noteSaveFailed => 'Falha ao salvar nota';

  @override
  String get noteColor => 'Cor da nota';

  @override
  String get imageInsertFailed => 'Falha ao inserir imagem';

  @override
  String get deleteNote => 'Excluir nota';

  @override
  String get pinNote => 'Fixar';

  @override
  String get unpinNote => 'Desafixar';

  @override
  String editedAt(String date) {
    return 'Editado $date';
  }

  @override
  String get back => 'Voltar';

  @override
  String get moreActions => 'Mais';

  @override
  String get formatting => 'Formatação';

  @override
  String get insertImage => 'Inserir imagem';

  @override
  String get undo => 'Desfazer';

  @override
  String get redo => 'Refazer';

  @override
  String get newLine => 'Nova linha';
}
