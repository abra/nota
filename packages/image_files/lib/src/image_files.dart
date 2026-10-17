import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared/shared.dart';

import 'image_files_exception.dart';

/// Manages image files stored in `<appDocuments>/nota_images/`.
///
/// Every picked image is copied into the app's documents directory under a
/// timestamp-based filename so the original can be removed from the gallery
/// without affecting the note.
class ImageFiles {
  static const _folder = 'nota_images';

  /// Returns the directory where note images are stored, creating it if needed.
  ///
  /// Throws [ImageFilesException] if the directory cannot be created.
  Future<Directory> _imagesDir() async {
    try {
      final base = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(base.path, _folder));
      if (!dir.existsSync()) await dir.create(recursive: true);
      return dir;
    } catch (e, st) {
      throw ImageFilesException('Failed to access images directory', e, st);
    }
  }

  /// Copies the file at [sourcePath] into the images directory.
  ///
  /// Returns the permanent path of the saved image.
  /// Throws [ImageFilesException] if the copy fails.
  Future<String> saveImage(String sourcePath) async {
    try {
      final dir = await _imagesDir();
      final ext = p.extension(sourcePath);
      final filename = '${DateTime.now().microsecondsSinceEpoch}$ext';
      final dest = File(p.join(dir.path, filename));
      await File(sourcePath).copy(dest.path);
      return dest.path;
    } on ImageFilesException {
      rethrow;
    } catch (e, st) {
      throw ImageFilesException('Failed to save image', e, st);
    }
  }

  /// Deletes the file at [imagePath]. Silently ignores missing files.
  Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (file.existsSync()) await file.delete();
  }

  /// Returns the paths of every image currently stored by the app.
  ///
  /// Returns an empty list when the directory does not exist yet.
  /// Throws [ImageFilesException] if the directory cannot be read.
  Future<List<String>> listImages() async {
    try {
      final base = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(base.path, _folder));
      if (!dir.existsSync()) return const [];
      return [
        await for (final entity in dir.list(followLinks: false))
          if (entity is File) entity.path,
      ];
    } catch (e, st) {
      throw ImageFilesException('Failed to list images', e, st);
    }
  }

  /// Deletes every stored image whose path is not in [referencedPaths].
  ///
  /// Used as an orphan sweep: notes may be deleted or abandoned while their
  /// images are already on disk. Errors on individual files are ignored so one
  /// locked file does not stop the sweep.
  Future<int> deleteUnreferenced(Set<String> referencedPaths) async {
    var removed = 0;
    for (final path in await listImages()) {
      if (referencedPaths.contains(path)) continue;
      try {
        await deleteImage(path);
        removed++;
      } catch (_) {}
    }
    return removed;
  }

  /// Deletes all images referenced inside the Quill Delta [content] string.
  Future<void> deleteImagesFromContent(String content) async {
    final paths = DeltaUtils.allImagePaths(content);
    for (final path in paths) {
      await deleteImage(path);
    }
  }
}
