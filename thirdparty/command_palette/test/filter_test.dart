import 'package:command_palette/src/utils/filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    "Fuzzy Filter",
    () {
      const String wordToMatchAgainst = "Close Command Palette";
      var result = Filter.matchesFuzzy("cl cmd p", wordToMatchAgainst);

      expect(result != null, true);
      expect(result!.length, 4);
      expect(
        wordToMatchAgainst.substring(result[0].start, result[0].end),
        "Cl",
      );
      expect(
        wordToMatchAgainst.substring(result[1].start, result[1].end),
        " C",
      );
      expect(
        wordToMatchAgainst.substring(result[2].start, result[2].end),
        "m",
      );
      expect(
        wordToMatchAgainst.substring(result[3].start, result[3].end),
        "d P",
      );

      result = Filter.matchesFuzzy("ccp", wordToMatchAgainst);

      expect(result != null, true);
      expect(result!.length, 3);
      expect(
        wordToMatchAgainst.substring(result[0].start, result[0].end),
        "C",
      );
      expect(
        wordToMatchAgainst.substring(result[1].start, result[1].end),
        "C",
      );
      expect(
        wordToMatchAgainst.substring(result[2].start, result[2].end),
        "P",
      );

      result = Filter.matchesFuzzy("ccccp", wordToMatchAgainst);

      expect(result, null);
    },
  );

  test(
    "Filter doesn't crash when back-slash entered",
    () {
      final result = Filter.matchesFuzzy(r'\', r'\my string\');

      expect(result, isNotNull);
    },
  );
}
