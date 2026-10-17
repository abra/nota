import 'package:image_files/image_files.dart';

class FakeImageFiles implements ImageFiles {
  final List<String> deletedPaths = [];
  bool shouldThrow = false;

  @override
  Future<String> saveImage(String sourcePath) async => sourcePath;

  @override
  Future<void> deleteImage(String imagePath) async {
    if (shouldThrow) throw ImageFilesException('deleteImage failed');
    deletedPaths.add(imagePath);
  }

  /// Paths passed to the last [deleteUnreferenced] call, for assertions.
  Set<String>? lastReferencedPaths;

  @override
  Future<List<String>> listImages() async => const [];

  @override
  Future<int> deleteUnreferenced(Set<String> referencedPaths) async {
    if (shouldThrow) throw ImageFilesException('deleteUnreferenced failed');
    lastReferencedPaths = referencedPaths;
    return 0;
  }

  @override
  Future<void> deleteImagesFromContent(String content) async {
    if (shouldThrow) {
      throw ImageFilesException('deleteImagesFromContent failed');
    }
  }
}
