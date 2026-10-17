import 'package:flutter_test/flutter_test.dart';
import 'package:note_details/src/checklist/checklist_splitter.dart';

void main() {
  List<String> split(String text, [String language = 'en']) =>
      splitIntoChecklistItems(text, languageCode: language);

  group('splitIntoChecklistItems', () {
    test('splits on commas, sentence ends and line breaks', () {
      expect(split('milk, bread. eggs!\ncoffee; tea?'), [
        'Milk',
        'Bread',
        'Eggs',
        'Coffee',
        'Tea',
      ]);
    });

    test('splits short phrases on the conjunction of the language', () {
      expect(split('bread and butter'), ['Bread', 'Butter']);
      expect(split('хлеб и масло', 'ru'), ['Хлеб', 'Масло']);
      expect(split('Brot und Butter', 'de'), ['Brot', 'Butter']);
      expect(split('pan y mantequilla', 'es'), ['Pan', 'Mantequilla']);
      expect(split('pain et beurre', 'fr'), ['Pain', 'Beurre']);
      expect(split('pão e manteiga', 'pt'), ['Pão', 'Manteiga']);
      expect(split('दूध और ब्रेड', 'hi'), ['दूध', 'ब्रेड']);
    });

    test('keeps long clauses joined by a conjunction together', () {
      expect(split('Call the dentist tomorrow and ask about the invoice'), [
        'Call the dentist tomorrow and ask about the invoice',
      ]);
    });

    test('splits scripts without spaces on their punctuation only', () {
      expect(split('牛乳、パン。卵', 'ja'), ['牛乳', 'パン', '卵']);
      expect(split('牛奶，面包。鸡蛋', 'zh'), ['牛奶', '面包', '鸡蛋']);
      expect(
        split('友達と出かける', 'ja'),
        ['友達と出かける'],
        reason: 'と is too ambiguous to split on',
      );
    });

    test('respects Arabic and Devanagari punctuation', () {
      expect(split('حليب، خبز؛ بيض', 'ar'), ['حليب', 'خبز', 'بيض']);
      expect(split('दूध। ब्रेड', 'hi'), ['दूध', 'ब्रेड']);
    });

    test(
      'drops list markers and empty pieces, capitalises the first letter',
      () {
        expect(split('- milk\n• bread\n2. eggs\n\n , '), [
          'Milk',
          'Bread',
          'Eggs',
        ]);
        expect(split('already Capital'), ['Already Capital']);
      },
    );

    test('splits on spaced dashes but not on hyphenated words', () {
      expect(split('milk - bread – eggs'), ['Milk', 'Bread', 'Eggs']);
      expect(split('well-known brand'), ['Well-known brand']);
    });

    test('returns nothing for blank input', () {
      expect(split(''), isEmpty);
      expect(split('   \n '), isEmpty);
    });

    test('languages without a conjunction rule still split on punctuation', () {
      expect(split('a, b and c', 'xx'), ['A', 'B and c']);
    });
  });
}
