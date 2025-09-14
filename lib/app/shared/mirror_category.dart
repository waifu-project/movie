import 'package:catmovie/app/extension.dart';
import 'package:catmovie/isar/schema/category_schema.dart';
import 'package:catmovie/utils/once.dart';
import 'package:flutter/widgets.dart';
import 'package:isar_community/isar.dart';
import 'package:xi/xi.dart';

/// NOTE(d1y): 获取分类最大尝试次数(3次)
const kMirrorCategoryTryCountMax = 3;

class CacheWithCategory {
  CacheWithCategory._internal();
  factory CacheWithCategory() => _instance;
  static final CacheWithCategory _instance = CacheWithCategory._internal();

  Map<String, List<SourceSpiderQueryCategory>> stacks = {};

  final Map<String, SourceSpiderQueryCategory> _lastUsedMap = {};

  void setLastUsed(String key, SourceSpiderQueryCategory category) {
    _lastUsedMap[key] = category;
  }

  SourceSpiderQueryCategory? getLastUsed(String key) {
    return _lastUsedMap[key];
  }

  void cleanupLastUsed() {
    _lastUsedMap.clear();
  }

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

  VoidCallback? _init;

  void init() async {
    _init ??= once(() {
      debugPrint("init sources category(OK)");
      var list = categoryAs.where().findAllSync();
      for (var item in list) {
        stacks[item.sid] = item.toRealCategories();
      }
    });
    _init!();
  }

  void clean() {
    stacks = {};
    isarInstance.writeTxnSync(() {
      categoryAs.clearSync();
    });
  }

  void put(String key, List<SourceSpiderQueryCategory> data) {
    stacks[key] = data;
    isarInstance.writeTxnSync(() {
      var categories = data.map((item) {
        var category = Category();
        category.id = item.id;
        category.name = item.name;
        return category;
      }).toList();
      var model = categoryAs.filter().sidEqualTo(key).findFirstSync();
      if (model == null) {
        categoryAs.putSync(CategoryIsarModel(sid: key, categories: categories));
        return;
      }
      model.categories = categories;
      categoryAs.putSync(model);
    });
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
