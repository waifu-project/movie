import 'package:xi/xi.dart';

/// NOTE(d1y): 获取分类最大尝试次数(3次)
const kMirrorCategoryTryCountMax = 3;

/// 源分类缓存池
/// TODO(d1y): 持久化
class MirrorCategoryPool {
  MirrorCategoryPool._internal();
  factory MirrorCategoryPool() => _instance;
  static final MirrorCategoryPool _instance = MirrorCategoryPool._internal();

  Map<String, List<SourceSpiderQueryCategory>> stacks = {};

  //===============================
  /// 标记一个最大数📌的请求分类池
  Map<String, int> fetchCounter = {};
  bool fetchCountAlreadyMax(String key) {
    int count = fetchCounter[key] ?? 0;
    return count >= kMirrorCategoryTryCountMax;
  }

  void fetchCountPP(String key) {
    int count = fetchCounter[key] ?? 0;
    fetchCounter[key] = count + 1;
  }

  void cleanCounter() {
    fetchCounter = {};
  }
  //===============================

  void clean() {
    stacks = {};
  }

  void put(String key, List<SourceSpiderQueryCategory> data) {
    stacks[key] = data;
  }

  List<SourceSpiderQueryCategory> data(String key) {
    return stacks[key] ?? [];
  }

  bool has(String key) {
    var stack = stacks[key];
    if (stack == null) return false;
    return stack.isNotEmpty;
  }
}
