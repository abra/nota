// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class NoteListLocalizationsPt extends NoteListLocalizations {
  NoteListLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String selected(int count) {
    return '$count selecionados';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas excluídas',
      one: 'Nota excluída',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'Sem notas';

  @override
  String get searchHint => 'Pesquisar';

  @override
  String get noteDeleteFailed => 'Falha ao excluir nota';

  @override
  String get noteUpdateFailed => 'Falha ao atualizar nota';

  @override
  String get loadFailed => 'Falha ao carregar notas';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get pinned => 'Fixadas';

  @override
  String get others => 'Outras';

  @override
  String get yesterday => 'Ontem';

  @override
  String get noResults => 'Nada encontrado';

  @override
  String get noResultsHint => 'Tente outro termo de busca';

  @override
  String get emptyStateHint => 'Toque em + para criar sua primeira nota';

  @override
  String get undo => 'Desfazer';

  @override
  String get addNote => 'Nova nota';

  @override
  String get menu => 'Menu';

  @override
  String get pin => 'Fixar';

  @override
  String get delete => 'Excluir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get noteRestoreFailed => 'Falha ao restaurar a nota';
}
