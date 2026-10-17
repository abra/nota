import 'dart:convert';

/// Utility for working with Quill Delta JSON stored in [Note.content].
///
/// [Note.content] can be either:
/// - Legacy plain text (old notes)
/// - Quill Delta JSON: `{"ops": [{"insert": "..."}, ...]}`
///
/// The `*Of(ops)` variants work on an already decoded ops list so callers that
/// need several facts about one note decode its JSON only once.
abstract final class DeltaUtils {
  /// Decodes [content] into a Quill ops list, handling both formats:
  /// - Canonical: `{"ops": [...]}`
  /// - Legacy bare array: `[...]`
  ///
  /// Returns null if [content] is not a recognized Delta format.
  static List<dynamic>? extractOps(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is Map) {
        final ops = decoded['ops'];
        if (ops is List) return ops;
      } else if (decoded is List) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  /// Returns true if [content] is a valid Quill Delta JSON string.
  ///
  /// Accepts both canonical `{"ops":[...]}` and legacy bare `[...]` formats.
  static bool isDelta(String content) => extractOps(content) != null;

  /// Extracts plain text from [content].
  ///
  /// If [content] is a Delta JSON, concatenates all text inserts.
  /// If [content] is plain text, returns it as-is.
  static String toPlainText(String content) {
    final ops = extractOps(content);
    return ops == null ? content : plainTextOf(ops);
  }

  /// Concatenates every text insert in [ops], trimming trailing whitespace.
  static String plainTextOf(List<dynamic> ops) {
    final buffer = StringBuffer();
    for (final op in ops) {
      if (op is Map) {
        final insert = op['insert'];
        if (insert is String) buffer.write(insert);
      }
    }
    return buffer.toString().trimRight();
  }

  /// Returns true if [content] has no meaningful text or embeds.
  static bool isContentEmpty(String content) {
    final ops = extractOps(content);
    if (ops == null) return content.trim().isEmpty;
    if (plainTextOf(ops).trim().isNotEmpty) return false;
    return !ops.any((op) => op is Map && op['insert'] is Map);
  }

  /// Returns the file path of the first image embed in [content], or null.
  static String? firstImagePath(String content) {
    final ops = extractOps(content);
    return ops == null ? null : firstImagePathOf(ops);
  }

  /// Returns the file path of the first image embed in [ops], or null.
  static String? firstImagePathOf(List<dynamic> ops) {
    for (final op in ops) {
      final path = _imagePathOf(op);
      if (path != null) return path;
    }
    return null;
  }

  /// Returns all image paths embedded in [content].
  static List<String> allImagePaths(String content) {
    final ops = extractOps(content);
    if (ops == null) return const [];
    return [for (final op in ops) ?_imagePathOf(op)];
  }

  static String? _imagePathOf(Object? op) {
    if (op is! Map) return null;
    final insert = op['insert'];
    if (insert is! Map) return null;
    final path = insert['image'];
    return path is String ? path : null;
  }

  /// Wraps [plainText] into a minimal Quill Delta JSON string.
  static String fromPlainText(String plainText) {
    final text = plainText.isEmpty ? '\n' : '$plainText\n';
    return jsonEncode({
      'ops': [
        {'insert': text},
      ],
    });
  }
}
