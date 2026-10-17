import 'package:flutter/widgets.dart' show TextSelection;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_details/src/dictation/dictation_mode.dart';
import 'package:note_details/src/dictation/quill_dictation_sink.dart';

void main() {
  late QuillController controller;
  late QuillDictationSink sink;

  QuillController controllerWith(List<Map<String, Object?>> ops) =>
      QuillController(
        document: Document.fromJson(ops),
        selection: const TextSelection.collapsed(offset: 0),
      );

  /// Plain text plus the list attribute of every line, for compact asserts.
  List<(String, String?)> lines() {
    final result = <(String, String?)>[];
    final current = StringBuffer();
    for (final op in controller.document.toDelta().toList()) {
      final data = op.data;
      if (data is! String) {
        current.write('\uFFFC');
        continue;
      }
      // A newline closes the line; only the newline op carries line styles.
      final parts = data.split('\n');
      for (var i = 0; i < parts.length; i++) {
        current.write(parts[i]);
        if (i < parts.length - 1) {
          result.add((current.toString(), op.attributes?['list'] as String?));
          current.clear();
        }
      }
    }
    return result;
  }

  void placeCursor(int offset) => controller.updateSelection(
    TextSelection.collapsed(offset: offset),
    ChangeSource.local,
  );

  setUp(() {
    controller = QuillController.basic();
    sink = QuillDictationSink(() => controller);
  });

  tearDown(() => controller.dispose());

  group('text mode', () {
    test('writes into an empty document and places the cursor after', () {
      sink.insert('Hello', DictationMode.text);
      expect(controller.document.toPlainText(), 'Hello\n');
      expect(controller.selection.extentOffset, 5);
    });

    test('separates consecutive utterances with a space', () {
      sink.insert('Hello', DictationMode.text);
      sink.insert('world', DictationMode.text);
      expect(controller.document.toPlainText(), 'Hello world\n');
    });

    test('adds spaces on both sides when inserted between words', () {
      controller = controllerWith([
        {'insert': 'Hello world\n'},
      ]);
      placeCursor(5);
      sink.insert('big', DictationMode.text);
      expect(controller.document.toPlainText(), 'Hello big world\n');
      expect(controller.selection.extentOffset, 9, reason: 'before the space');
    });

    test('adds no space after a space or at a line start', () {
      controller = controllerWith([
        {'insert': 'Hello \n'},
      ]);
      placeCursor(6);
      sink.insert('there', DictationMode.text);
      expect(controller.document.toPlainText(), 'Hello there\n');
    });

    test('ignores empty text', () {
      sink.insert('', DictationMode.text);
      expect(controller.document.toPlainText(), '\n');
    });
  });

  group('list mode', () {
    test('turns an empty document into a bullet item', () {
      sink.insert('Milk', DictationMode.list);
      expect(lines(), [('Milk', 'bullet')]);
    });

    test('adds each utterance as a new item', () {
      sink.insert('Milk', DictationMode.list);
      sink.insert('Bread', DictationMode.list);
      sink.insert('Eggs', DictationMode.list);
      expect(lines(), [
        ('Milk', 'bullet'),
        ('Bread', 'bullet'),
        ('Eggs', 'bullet'),
      ]);
      expect(controller.selection.extentOffset, 'Milk\nBread\nEggs'.length);
    });

    test('keeps a numbered list numbered', () {
      controller = controllerWith([
        {'insert': 'First'},
        {
          'insert': '\n',
          'attributes': {'list': 'ordered'},
        },
      ]);
      placeCursor(5);
      sink.insert('Second', DictationMode.list);
      expect(lines(), [('First', 'ordered'), ('Second', 'ordered')]);
    });

    test('fills an empty line instead of adding one', () {
      controller = controllerWith([
        {'insert': 'Milk'},
        {
          'insert': '\n',
          'attributes': {'list': 'bullet'},
        },
        {
          'insert': '\n',
          'attributes': {'list': 'bullet'},
        },
      ]);
      placeCursor(5);
      sink.insert('Bread', DictationMode.list);
      expect(lines(), [('Milk', 'bullet'), ('Bread', 'bullet')]);
    });

    test('starts the new item below the cursor line, not mid-line', () {
      controller = controllerWith([
        {'insert': 'Oat milk'},
        {
          'insert': '\n',
          'attributes': {'list': 'unchecked'},
        },
        {'insert': 'Lemons'},
        {
          'insert': '\n',
          'attributes': {'list': 'unchecked'},
        },
      ]);
      placeCursor(3); // inside "Oat milk"
      sink.insert('Bread', DictationMode.checklist);
      expect(lines(), [
        ('Oat milk', 'unchecked'),
        ('Bread', 'unchecked'),
        ('Lemons', 'unchecked'),
      ]);
    });
  });

  group('checklist mode', () {
    test('creates unchecked items', () {
      sink.insert('Milk', DictationMode.checklist);
      sink.insert('Bread', DictationMode.checklist);
      expect(lines(), [('Milk', 'unchecked'), ('Bread', 'unchecked')]);
    });

    test('new items after a checked item are unchecked', () {
      controller = controllerWith([
        {'insert': 'Milk'},
        {
          'insert': '\n',
          'attributes': {'list': 'checked'},
        },
      ]);
      placeCursor(4);
      sink.insert('Bread', DictationMode.checklist);
      expect(lines(), [('Milk', 'checked'), ('Bread', 'unchecked')]);
    });

    test('converts a plain paragraph line into a checklist', () {
      controller = controllerWith([
        {'insert': 'Shopping\n'},
      ]);
      placeCursor(8);
      sink.insert('Milk', DictationMode.checklist);
      expect(lines(), [('Shopping', null), ('Milk', 'unchecked')]);
    });
  });

  group('cursor handling', () {
    test('appends at the end when the selection is invalid', () {
      controller = controllerWith([
        {'insert': 'Hello\n'},
      ]);
      controller.updateSelection(
        const TextSelection.collapsed(offset: -1),
        ChangeSource.local,
      );
      sink.insert('world', DictationMode.text);
      expect(controller.document.toPlainText(), 'Hello world\n');
    });

    test('inserts at the end of a range selection', () {
      controller = controllerWith([
        {'insert': 'Hello world\n'},
      ]);
      controller.updateSelection(
        const TextSelection(baseOffset: 0, extentOffset: 5),
        ChangeSource.local,
      );
      sink.insert('big', DictationMode.text);
      expect(controller.document.toPlainText(), 'Hello big world\n');
    });
  });

  group('newLine, undo and modeAtCursor', () {
    test('newLine inserts a line break at the cursor', () {
      sink.insert('Hello', DictationMode.text);
      sink.newLine();
      expect(controller.document.toPlainText(), 'Hello\n\n');
      expect(controller.selection.extentOffset, 6);
    });

    test('newLine inside a list keeps the list style', () {
      sink.insert('Milk', DictationMode.list);
      sink.newLine();
      expect(lines(), [('Milk', 'bullet'), ('', 'bullet')]);
    });

    test('undo removes the last dictated utterance only', () async {
      sink.insert('Milk', DictationMode.list);
      // Quill merges edits closer than its history interval into one entry.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      sink.insert('Bread', DictationMode.list);
      sink.undo();
      expect(lines(), [('Milk', 'bullet')]);
    });

    test('undo with an empty history is a no-op', () {
      sink.undo();
      expect(controller.document.toPlainText(), '\n');
    });

    test('modeAtCursor follows the line under the cursor', () {
      controller = controllerWith([
        {'insert': 'Para\n'},
        {'insert': 'Bullet'},
        {
          'insert': '\n',
          'attributes': {'list': 'bullet'},
        },
        {'insert': 'Number'},
        {
          'insert': '\n',
          'attributes': {'list': 'ordered'},
        },
        {'insert': 'Todo'},
        {
          'insert': '\n',
          'attributes': {'list': 'checked'},
        },
      ]);
      placeCursor(2);
      expect(sink.modeAtCursor(), DictationMode.text);
      placeCursor(7);
      expect(sink.modeAtCursor(), DictationMode.list);
      placeCursor(14);
      expect(sink.modeAtCursor(), DictationMode.list);
      placeCursor(21);
      expect(sink.modeAtCursor(), DictationMode.checklist);
    });
  });
}
