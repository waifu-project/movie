import 'dart:collection';

/// filter functions return either a list of matches, or null if nothing was
/// found
typedef FilterFunction = List<FilterMatch>? Function(
    String word, String wordToMatchAgainst);

/// A match for a given String. Has the start and end indices of the substring
/// containing the match
class FilterMatch {
  int start;
  int end;

  FilterMatch(this.start, this.end);
}

/// Collection of various String based filters. Everything in here is an
/// adaptation of the filtering library used in VSCode
class Filter {
  /// Returns a filter which combines the provided set of filters. Returning the
  /// first filter which provides a match, or null if no filters provide
  /// such a match
  static FilterFunction or(List<FilterFunction> filters) {
    return (String word, String wordToMatchAgainst) {
      for (int i = 0; i < filters.length; i++) {
        final match = filters[i](word, wordToMatchAgainst);
        if (match != null) {
          return match;
        }
      }
      return null;
    };
  }

  /// Returns a match if [word] is the prefix of [wordToMatch]
  static List<FilterMatch>? matchesPrefix(
      String word, String wordToMatchAgainst) {
    word = word.toLowerCase();
    wordToMatchAgainst = wordToMatchAgainst.toLowerCase();
    if (wordToMatchAgainst.length < word.length) {
      return null;
    }
    bool matches = wordToMatchAgainst.indexOf(word) == 0;

    if (!matches) {
      return null;
    }

    return word.isNotEmpty ? [FilterMatch(0, word.length)] : [];
  }

  /// Joins [head] with the list of matches [tail]
  static List<FilterMatch> join(FilterMatch head, List<FilterMatch> tail) {
    if (tail.isEmpty) {
      tail = [head];
    } else if (head.end == tail[0].start) {
      tail[0].start = head.start;
    } else {
      tail.insert(0, head);
    }

    return tail;
  }

  static final LinkedHashMap<String, RegExp> _fuzzyRegExCache =
      LinkedHashMap<String, RegExp>();

  /// Matches words in a fuzzy way
  static List<FilterMatch>? matchesFuzzy(
      String word, String wordToMatchAgainst) {
    word = word.toLowerCase();
    wordToMatchAgainst = wordToMatchAgainst.toLowerCase();
    RegExp? regExp = _fuzzyRegExCache[word];

    // form RegExp for wildcard matches
    if (regExp == null) {
      regExp = RegExp(convertToRegExpPattern(word), caseSensitive: false);
      _fuzzyRegExCache[word] = regExp;
    }

    // RegExp Filter
    final match = regExp.firstMatch(wordToMatchAgainst);
    if (match != null) {
      return [FilterMatch(match.start, match.end)];
    }

    return or([Filter.matchesPrefix, Filter.matchesSubString])(
        word, wordToMatchAgainst);
  }

  static String convertToRegExpPattern(String word) {
    return RegExp.escape(word
        .replaceAll(r'/[\-\\\{\}\+\?\|\^\$\.\,\[\]\(\)\#\s]/g', '\\\$&')
        .replaceAll(r"/[\*]/g", ".*"));
  }

  /// Matches a non-contiguous sub-string
  static List<FilterMatch>? matchesSubString(
      String word, String wordToMatchAgainst) {
    word = word.toLowerCase();
    wordToMatchAgainst = wordToMatchAgainst.toLowerCase();
    return _matchesSubString(word, wordToMatchAgainst, 0, 0);
  }

  static List<FilterMatch>? _matchesSubString(
      String word, String wordToMatchAgainst, int i, int j) {
    if (i == word.length) {
      return [];
    } else if (j == wordToMatchAgainst.length) {
      return null;
    } else {
      if (word[i] == wordToMatchAgainst[j]) {
        List<FilterMatch>? result =
            _matchesSubString(word, wordToMatchAgainst, i + 1, j + 1);
        if (result != null) {
          return join(FilterMatch(j, j + 1), result);
        }
        return null;
      }

      return _matchesSubString(word, wordToMatchAgainst, i, j + 1);
    }
  }
}
