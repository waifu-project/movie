import 'package:movie/impl/movie.dart';

class MirrorCategory {
  MirrorCategory._internal();
  factory MirrorCategory() => _instance;
  static late final MirrorCategory _instance = MirrorCategory._internal();

  Map<String, List<MovieQueryCategory>> stacks = {};

  clean() {
    stacks = {};
  }

  put(String key, List<MovieQueryCategory> data) {
    stacks[key] = data;
  }

  List<MovieQueryCategory> data(String key) {
    return stacks[key] ?? [];
  }

  bool has(String key) {
    var stack = stacks[key];
    if (stack == null) return false;
    return stack.isNotEmpty;
  }
}
