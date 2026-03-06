abstract final class AppRoutes {
  static const notes = '/notes';
  static const newNote = '/notes/new';
  static const settings = '/settings';

  static String noteEditor(String id) => '/notes/$id';
}
