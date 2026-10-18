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

  @override
  String get dictate => 'Ditar';

  @override
  String get dictationModeText => 'Texto';

  @override
  String get dictationModeList => 'Lista';

  @override
  String get dictationModeChecklist => 'Lista de tarefas';

  @override
  String get dictationStarting => 'Iniciando…';

  @override
  String get dictationListening => 'Ouvindo…';

  @override
  String get dictationPaused => 'Pausado. Toque no microfone para continuar';

  @override
  String get dictationHintList => 'Ouvindo… faça uma pausa entre os itens';

  @override
  String dictationHintNewLine(String phrase) {
    return 'Ouvindo… diga “$phrase” para uma nova linha';
  }

  @override
  String get dictationPause => 'Pausar ditado';

  @override
  String get dictationResume => 'Retomar ditado';

  @override
  String get dictationPermissionDenied =>
      'Permita o acesso ao microfone e ao reconhecimento de voz nos Ajustes';

  @override
  String get dictationUnavailable =>
      'O reconhecimento de voz não está disponível neste dispositivo';

  @override
  String get dictationLanguageUnsupported =>
      'O reconhecimento de voz não está disponível para este idioma';

  @override
  String get dictationNetworkError =>
      'O reconhecimento de voz precisa de conexão de rede';

  @override
  String get dictationFailed => 'O ditado parou devido a um erro';

  @override
  String get openSettings => 'Ajustes';

  @override
  String get dictateNote => 'Ditar uma nota';

  @override
  String get convertToChecklist => 'Parágrafo em lista de tarefas';

  @override
  String get dictationLanguage => 'Idioma do ditado';

  @override
  String get dictationLanguagesRecent => 'Recentes';

  @override
  String get dictationLanguagesAll => 'Todos os idiomas';

  @override
  String get dictationLanguagesUnavailable =>
      'O reconhecimento de voz não informou os idiomas. Verifique o acesso ao microfone e ao reconhecimento de voz.';
}
