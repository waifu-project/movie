import 'package:movie/spider/abstract/spider_movie.dart';

/// NOTE(d1y): 获取分类最大尝试次数(3次)
const kMirrorCategoryTryCountMax = 3;

/// 源分类缓存池
/// TODO(d1y): 持久化
class MirrorCategoryPool {
  MirrorCategoryPool._internal();
  factory MirrorCategoryPool() => _instance;
  static late final MirrorCategoryPool _instance =
      MirrorCategoryPool._internal();

  Map<String, List<SpiderQueryCategory>> stacks = {};

  //===============================
  /// 标记一个最大数📌的请求分类池
  Map<String, int> fetchCounter = {};
  bool fetchCountAlreadyMax(String key) {
    int count = fetchCounter[key] ?? 0;
    return count >= kMirrorCategoryTryCountMax;
  }

  fetchCountPP(String key) {
    int count = fetchCounter[key] ?? 0;
    fetchCounter[key] = count + 1;
  }

  cleanCounter() {
    fetchCounter = {};
  }
  //===============================

  clean() {
    stacks = {};
  }

  put(String key, List<SpiderQueryCategory> data) {
    stacks[key] = data;
  }

  List<SpiderQueryCategory> data(String key) {
    return stacks[key] ?? [];
  }

  bool has(String key) {
    var stack = stacks[key];
    if (stack == null) return false;
    return stack.isNotEmpty;
  }
}
