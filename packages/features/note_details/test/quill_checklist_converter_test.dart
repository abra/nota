import 'package:flutter/widgets.dart' show TextSelection;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_details/src/checklist/quill_checklist_converter.dart';

void main() {
  late QuillController controller;

  QuillController controllerWith(List<Map<String, Object?>> ops) =>
      QuillController(
        document: Document.fromJson(ops),
        selection: const TextSelection.collapsed(offset: 0),
      );

  List<(String, String?)> lines() {
    final result = <(String, String?)>[];
    final current = StringBuffer();
    for (final op in controller.document.toDelta().toList()) {
      final data = op.data;
      if (data is! String) {
        current.write('￼');
        continue;
      }
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

  tearDown(() => controller.dispose());

  test('turns the paragraph under the cursor into checklist items', () {
    controller = controllerWith([
      {'insert': 'Title line\nmilk, bread and eggs. call mum\nTail\n'},
    ]);
    placeCursor(15); // inside the second line

    expect(
      convertParagraphToChecklist(controller, languageCode: 'en'),
      isTrue,
    );
    expect(lines(), [
      ('Title line', null),
      ('Milk', 'unchecked'),
      ('Bread', 'unchecked'),
      ('Eggs', 'unchecked'),
      ('Call mum', 'unchecked'),
      ('Tail', null),
    ]);
    expect(
      controller.document.toPlainText(),
      'Title line\nMilk\nBread\nEggs\nCall mum\nTail\n',
    );
  });

  test('places the cursor at the end of the new items', () {
    controller = controllerWith([
      {'insert': 'a, b\n'},
    ]);
    convertParagraphToChecklist(controller, languageCode: 'en');
    expect(controller.selection.extentOffset, 'A\nB'.length);
  });

  test('leaves an empty line alone', () {
    controller = QuillController.basic();
    expect(
      convertParagraphToChecklist(controller, languageCode: 'en'),
      isFalse,
    );
    expect(controller.document.toPlainText(), '\n');
  });

  test('leaves a line with an embed alone', () {
    controller = controllerWith([
      {
        'insert': {'image': '/tmp/a.png'},
      },
      {'insert': '\n'},
    ]);
    expect(
      convertParagraphToChecklist(controller, languageCode: 'en'),
      isFalse,
    );
  });

  test('a single phrase becomes one checklist item', () {
    controller = controllerWith([
      {'insert': 'buy olive oil\n'},
    ]);
    convertParagraphToChecklist(controller, languageCode: 'en');
    expect(lines(), [('Buy olive oil', 'unchecked')]);
  });

  test('works on the last line when the selection is invalid', () {
    controller = controllerWith([
      {'insert': 'first\nmilk, eggs\n'},
    ]);
    controller.updateSelection(
      const TextSelection.collapsed(offset: -1),
      ChangeSource.local,
    );
    convertParagraphToChecklist(controller, languageCode: 'en');
    expect(lines(), [
      ('first', null),
      ('Milk', 'unchecked'),
      ('Eggs', 'unchecked'),
    ]);
  });
}
