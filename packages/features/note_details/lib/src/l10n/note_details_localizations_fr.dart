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
}
