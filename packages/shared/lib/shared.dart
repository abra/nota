// Domain models, interfaces, and value objects shared across features.
//
// Features import this package to access common types without depending
// on each other. Concrete implementations are wired in composition.dart.
//
// Structure:
//   models/      — domain entities (Note, User, ...)
//   interfaces/  — repository and service abstractions
//   value_objects/ — typed wrappers (NoteId, Email, ...)
