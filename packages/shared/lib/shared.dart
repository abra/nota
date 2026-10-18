// Domain models and value objects shared across features.
//
// Features import this package to access common types without depending
// on each other. Concrete implementations are wired in composition.dart.

export 'src/exceptions/note_not_found_exception.dart';
export 'src/exceptions/note_storage_exception.dart';
export 'src/models/note.dart';
export 'src/models/dictation_language.dart';
export 'src/models/dictation_pause.dart';
export 'src/models/note_color.dart';
export 'src/models/note_list_density.dart';
export 'src/models/note_view_mode.dart';
export 'src/models/supported_language.dart';
export 'src/utils/delta_utils.dart';
