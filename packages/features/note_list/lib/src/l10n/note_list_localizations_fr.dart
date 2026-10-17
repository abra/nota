// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class NoteListLocalizationsFr extends NoteListLocalizations {
  NoteListLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String selected(int count) {
    return '$count sélectionnés';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes supprimées',
      one: 'Note supprimée',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'Aucune note';

  @override
  String get searchHint => 'Rechercher';

  @override
  String get noteDeleteFailed => 'Échec de la suppression de la note';

  @override
  String get noteUpdateFailed => 'Échec de la mise à jour de la note';

  @override
  String get loadFailed => 'Échec du chargement des notes';

  @override
  String get retry => 'Réessayer';

  @override
  String get pinned => 'Épinglées';

  @override
  String get others => 'Autres';

  @override
  String get yesterday => 'Hier';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String get noResultsHint => 'Essayez un autre terme';

  @override
  String get emptyStateHint => 'Appuyez sur + pour créer votre première note';

  @override
  String get undo => 'Annuler';

  @override
  String get addNote => 'Nouvelle note';

  @override
  String get menu => 'Menu';

  @override
  String get pin => 'Épingler';

  @override
  String get delete => 'Supprimer';

  @override
  String get cancel => 'Annuler';

  @override
  String get noteRestoreFailed => 'Impossible de restaurer la note';
}
