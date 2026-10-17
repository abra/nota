// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class NoteDetailsLocalizationsFr extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get newNote => 'Nouvelle note';

  @override
  String get editNote => 'Modifier la note';

  @override
  String get titleHint => 'Titre';

  @override
  String get contentHint => 'Commencez à écrire...';

  @override
  String get noteNotFound => 'Note introuvable';

  @override
  String get noteLoadFailed => 'Échec du chargement de la note';

  @override
  String get noteSaveFailed => 'Échec de la sauvegarde de la note';

  @override
  String get noteColor => 'Couleur de la note';

  @override
  String get imageInsertFailed => 'Échec de l\'insertion de l\'image';

  @override
  String get deleteNote => 'Supprimer la note';

  @override
  String get pinNote => 'Épingler';

  @override
  String get unpinNote => 'Désépingler';

  @override
  String editedAt(String date) {
    return 'Modifié $date';
  }

  @override
  String get back => 'Retour';

  @override
  String get moreActions => 'Plus';

  @override
  String get formatting => 'Mise en forme';

  @override
  String get insertImage => 'Insérer une image';

  @override
  String get undo => 'Annuler';

  @override
  String get redo => 'Rétablir';

  @override
  String get newLine => 'Nouvelle ligne';

  @override
  String get dictate => 'Dicter';

  @override
  String get dictationModeText => 'Texte';

  @override
  String get dictationModeList => 'Liste';

  @override
  String get dictationModeChecklist => 'Liste de tâches';

  @override
  String get dictationStarting => 'Démarrage…';

  @override
  String get dictationListening => 'J’écoute…';

  @override
  String get dictationPaused => 'En pause. Touchez le micro pour continuer';

  @override
  String get dictationHintList =>
      'J’écoute… marquez une pause entre les éléments';

  @override
  String dictationHintNewLine(String phrase) {
    return 'J’écoute… dites « $phrase » pour une nouvelle ligne';
  }

  @override
  String get dictationPause => 'Mettre la dictée en pause';

  @override
  String get dictationResume => 'Reprendre la dictée';

  @override
  String get dictationPermissionDenied =>
      'Autorisez l’accès au micro et à la reconnaissance vocale dans les Réglages';

  @override
  String get dictationUnavailable =>
      'La reconnaissance vocale n’est pas disponible sur cet appareil';

  @override
  String get dictationLanguageUnsupported =>
      'La reconnaissance vocale n’est pas disponible pour cette langue';

  @override
  String get dictationNetworkError =>
      'La reconnaissance vocale nécessite une connexion réseau';

  @override
  String get dictationFailed => 'La dictée s’est arrêtée à cause d’une erreur';
}
