import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:amategeko_app/data/models.dart';

Question _q(List<String> options, int correct) => Question(
      id: 'q',
      categoryId: 'c',
      text: 'Ikibazo',
      options: options,
      correctIndex: correct,
      explanation: '',
    );

void main() {
  test('"a na b" options point at the new letters of the right options', () {
    // Originals: a = Alpha, b = Bravo, c = Charlie, d = "a na b ni ibisubizo by'ukuri".
    final Question q = _q(<String>[
      'Alpha',
      'Bravo',
      'Charlie',
      'a na b ni ibisubizo by\'ukuri',
    ], 3);
    for (int seed = 0; seed < 200; seed++) {
      final Question s = q.shuffled(Random(seed));
      // The combo option stays last and is still the correct one.
      expect(s.options.last.startsWith(RegExp(r'[ab] na [bcd]')), isTrue, reason: s.options.toString());
      expect(s.correctIndex, 3);
      // The letters it names must be the positions of Alpha and Bravo.
      final String a = String.fromCharCode(97 + s.options.indexOf('Alpha'));
      final String b = String.fromCharCode(97 + s.options.indexOf('Bravo'));
      final List<String> named = <String>[a, b]..sort();
      expect(s.options.last, startsWith('${named[0]} na ${named[1]}'), reason: 'seed $seed: ${s.options}');
    }
  });

  test('upper-case "A na C nibyo" is remapped too', () {
    final Question q = _q(<String>['One', 'Two', 'Three', 'A na C nibyo'], 3);
    for (int seed = 0; seed < 100; seed++) {
      final Question s = q.shuffled(Random(seed));
      final String a = String.fromCharCode(65 + s.options.indexOf('One'));
      final String c = String.fromCharCode(65 + s.options.indexOf('Three'));
      final List<String> named = <String>[a, c]..sort();
      expect(s.options.last, '${named[0]} na ${named[1]} nibyo', reason: s.options.toString());
    }
  });

  test('"all / none of the above" options stay at the end', () {
    final Question q = _q(<String>[
      'Alpha',
      'Nta gisubizo cy\'ukuri kirimo',
      'Bravo',
      'Ibisubizo byose nibyo',
    ], 3);
    for (int seed = 0; seed < 100; seed++) {
      final Question s = q.shuffled(Random(seed));
      expect(s.options[2], 'Nta gisubizo cy\'ukuri kirimo');
      expect(s.options[3], 'Ibisubizo byose nibyo');
      expect(s.correctIndex, 3);
    }
  });

  test('letters inside a sentence (licence categories) are left alone', () {
    final Question q = _q(<String>[
      'Uruhushya rwa A na B',
      'Uruhushya rwa C',
      'Uruhushya rwa D',
      'Nta na kimwe',
    ], 0);
    for (int seed = 0; seed < 50; seed++) {
      final Question s = q.shuffled(Random(seed));
      expect(s.options, contains('Uruhushya rwa A na B'));
    }
  });

  test('"b na d": the combo can sit in the middle and still names the right options', () {
    // Originals: a = Alpha, b = Bravo, c = combo ("b na d"), d = Delta.
    final Question q = _q(<String>[
      'Alpha',
      'Bravo',
      "b na d ni ibisubizo by'ukuri",
      'Delta',
    ], 2);
    for (int seed = 0; seed < 200; seed++) {
      final Question s = q.shuffled(Random(seed));
      final String b = String.fromCharCode(97 + s.options.indexOf('Bravo'));
      final String d = String.fromCharCode(97 + s.options.indexOf('Delta'));
      final List<String> named = <String>[b, d]..sort();
      expect(s.options.last, startsWith('${named[0]} na ${named[1]}'), reason: 'seed $seed: ${s.options}');
      expect(s.correctIndex, 3);
    }
  });

  test('a question with missing options never crashes the shuffle', () {
    // Only two options arrived, but the combo answer mentions letters C and D.
    final Question q = _q(<String>['Alpha', "b na d ni ibisubizo by'ukuri"], 1);
    for (int seed = 0; seed < 50; seed++) {
      final Question s = q.shuffled(Random(seed));
      expect(s.options.length, 2);
    }
    // One option only.
    expect(_q(<String>['Alpha'], 0).shuffled(Random(1)).options, <String>['Alpha']);
  });
}
