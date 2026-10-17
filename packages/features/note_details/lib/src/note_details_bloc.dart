import 'dart:math' show Random;

import 'package:equatable/equatable.dart' show Equatable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_files/image_files.dart';
import 'package:note_repository/note_repository.dart';
import 'package:shared/shared.dart';

part 'note_details_event.dart';
part 'note_details_state.dart';

class NoteDetailsBloc extends Bloc<NoteDetailsEvent, NoteDetailsState> {
  NoteDetailsBloc({
    required NoteRepository noteRepository,
    required ImageFiles imageFiles,
    required bool isNew,
  }) : _repository = noteRepository,
       _imageFiles = imageFiles,
       super(NoteDetailsState(isNew: isNew)) {
    on<NoteDetailsStarted>(_onStarted);
    on<NoteDetailsTitleChanged>(_onTitleChanged);
    on<NoteDetailsContentChanged>(_onContentChanged);
    on<NoteDetailsColorChanged>(_onColorChanged);
    on<NoteDetailsPinToggled>(_onPinToggled);
    on<NoteDetailsSaved>(_onSaved);
    on<NoteDetailsDeleteRequested>(_onDeleteRequested);
    on<NoteDetailsImageInserted>(_onImageInserted);
  }

  final NoteRepository _repository;
  final ImageFiles _imageFiles;

  static final _random = Random();

  static final _colorChoices = NoteColor.values
      .where((c) => c != NoteColor.none)
      .toList();

  NoteColor _pickColor(NoteColor? last) {
    final candidates = last == null
        ? _colorChoices
        : _colorChoices.where((c) => c != last).toList();
    return candidates[_random.nextInt(candidates.length)];
  }

  Future<void> _onStarted(
    NoteDetailsStarted event,
    Emitter<NoteDetailsState> emit,
  ) async {
    if (event.noteId == null) {
      try {
        final lastColor = await _repository.getLastCreatedNoteColor();
        emit(state.copyWith(color: _pickColor(lastColor)));
      } on NoteStorageException catch (e, st) {
        addError(e, st);
        emit(state.copyWith(color: _pickColor(null)));
      }
      return;
    }

    emit(state.copyWith(status: NoteDetailsStatus.loading));
    try {
      final note = await _repository.getNoteById(event.noteId!);
      if (note == null) throw NoteNotFoundException(event.noteId!);
      emit(
        state.copyWith(
          status: NoteDetailsStatus.success,
          title: note.title ?? '',
          content: note.content,
          originalContent: note.content,
          color: note.color,
          isPinned: note.isPinned,
          note: note,
        ),
      );
    } on NoteNotFoundException catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: NoteDetailsStatus.failure, loadError: e));
    } on NoteStorageException catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: NoteDetailsStatus.failure, loadError: e));
    }
  }

  void _onTitleChanged(
    NoteDetailsTitleChanged event,
    Emitter<NoteDetailsState> emit,
  ) {
    emit(state.copyWith(title: event.title));
  }

  void _onContentChanged(
    NoteDetailsContentChanged event,
    Emitter<NoteDetailsState> emit,
  ) {
    // Clear insertedImagePath: the view has already consumed it to insert the
    // embed, and the resulting content change is what triggers this handler.
    emit(state.copyWith(content: event.content, insertedImagePath: null));
  }

  Future<void> _onImageInserted(
    NoteDetailsImageInserted event,
    Emitter<NoteDetailsState> emit,
  ) async {
    try {
      final permanentPath = await _imageFiles.saveImage(event.sourcePath);
      emit(state.copyWith(insertedImagePath: permanentPath));
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(imageInsertError: e));
    }
  }

  void _onColorChanged(
    NoteDetailsColorChanged event,
    Emitter<NoteDetailsState> emit,
  ) {
    emit(state.copyWith(color: event.color));
  }

  void _onPinToggled(
    NoteDetailsPinToggled event,
    Emitter<NoteDetailsState> emit,
  ) {
    emit(state.copyWith(isPinned: !state.isPinned));
  }

  /// Deletes image files from [content] only if no other note references them.
  Future<void> _deleteUnreferencedImages(String content) async {
    for (final path in DeltaUtils.allImagePaths(content)) {
      try {
        if (!await _repository.isImageReferenced(path)) {
          await _imageFiles.deleteImage(path);
        }
      } catch (e, st) {
        addError(e, st);
      }
    }
  }

  Future<void> _onDeleteRequested(
    NoteDetailsDeleteRequested event,
    Emitter<NoteDetailsState> emit,
  ) async {
    final note = state.note;
    if (note == null) return;
    if (state.isSaveInProgress) return;
    try {
      await _repository.deleteNote(note.id);
    } on NoteStorageException catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: NoteDetailsStatus.failure, saveError: e));
      return;
    }
    await _deleteUnreferencedImages(note.content);
    emit(state.copyWith(status: NoteDetailsStatus.deleted));
  }

  Future<void> _onSaved(
    NoteDetailsSaved event,
    Emitter<NoteDetailsState> emit,
  ) async {
    if (state.isContentEmpty && state.title.trim().isEmpty) return;
    // A second back press while saving must not start another save.
    if (state.isSaveInProgress) return;

    emit(state.copyWith(status: NoteDetailsStatus.saving));
    final title = state.title.trim().isEmpty ? null : state.title.trim();
    final content = DeltaUtils.isDelta(state.content)
        ? state.content
        : state.content.trim();
    try {
      Note saved;
      if (state.isNew) {
        saved = await _repository.createNote(
          title: title,
          content: content,
          color: state.color,
          isPinned: state.isPinned,
        );
      } else {
        final note = state.note;
        if (note == null) {
          emit(
            state.copyWith(
              status: NoteDetailsStatus.failure,
              saveError: StateError(
                'Cannot update note: note is null in state',
              ),
            ),
          );
          return;
        }
        saved = await _repository.updateNote(
          note.copyWith(
            title: title,
            content: content,
            color: state.color,
            isPinned: state.isPinned,
          ),
        );
        // Delete images that were in the original content but removed by the
        // user during editing. Non-fatal: note is already saved successfully.
        final oldPaths = DeltaUtils.allImagePaths(note.content).toSet();
        final newPaths = DeltaUtils.allImagePaths(content).toSet();
        for (final path in oldPaths.difference(newPaths)) {
          try {
            if (!await _repository.isImageReferenced(path)) {
              await _imageFiles.deleteImage(path);
            }
          } catch (e, st) {
            addError(e, st);
          }
        }
      }
      emit(
        state.copyWith(
          status: NoteDetailsStatus.saved,
          note: saved,
          isNew: false,
        ),
      );
    } on NoteStorageException catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: NoteDetailsStatus.failure, saveError: e));
    }
  }
}
