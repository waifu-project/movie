import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:movie/app/modules/home/views/mirrortable.dart';
import 'package:movie/app/shared/mirror_category.dart';
import 'package:movie/app/shared/mirror_status_stack.dart';
import 'package:movie/impl/movie.dart';
import 'package:movie/isar/schema/parse_schema.dart';
import 'package:movie/mirror/mirror.dart';
import 'package:movie/mirror/mirror_serialize.dart';
import 'package:movie/shared/enum.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import 'package:movie/app/extension.dart';

const kAllCategoryPoint = '-114514';
var kAllCategoryData = MovieQueryCategory('全部', kAllCategoryPoint);

/// 历史记录处理类型
enum UpdateSearchHistoryType {
  /// 添加
  add,

  /// 删除
  remove,

  /// 清除所有
  clean
}

class HomeController extends GetxController with WidgetsBindingObserver {
  late Size windowLastSize;

  var currentBarIndex = 0;

  PageController currentBarController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  int _currentParseVipIndex = 0;
  List<ParseIsarModel> _parseVipList = [];
  int get currentParseVipIndex => _currentParseVipIndex;
  List<ParseIsarModel> get parseVipList => _parseVipList;
  ParseIsarModel? get currentParseVipModelData {
    if (parseVipList.isEmpty || currentParseVipIndex >= parseVipList.length) {
      return null;
    }
    return parseVipList[currentParseVipIndex];
  }

  final mirrorCategoryPool = MirrorCategoryPool();

  String get currentMirrorItemId {
    if (mirrorListIsEmpty) return "";
    return currentMirrorItem.meta.id;
  }

  bool _iosCanBeUseSystemBrowser = true;

  List<MovieQueryCategory> get currentCategoryer {
    var data = mirrorCategoryPool.data(currentMirrorItemId);
    if (data.isNotEmpty) {
      return [kAllCategoryData, ...data];
    }
    return data;
  }

  bool get currentHasCategoryer {
    return mirrorCategoryPool.has(currentMirrorItemId);
  }

  MovieQueryCategory? currentCategoryerNow = kAllCategoryData;

  setCurrentCategoryerNow(MovieQueryCategory category) {
    currentCategoryerNow = category;
    // FIXME(d1y): 初始化
    updateHomeData(
      isFirst: true,
    );
    update();
  }

  bool get iosCanBeUseSystemBrowser =>
      _iosCanBeUseSystemBrowser && GetPlatform.isIOS && !GetPlatform.isLinux;

  set iosCanBeUseSystemBrowser(bool newVal) {
    _iosCanBeUseSystemBrowser = newVal;
    update();
    updateSetting(SettingsAllKey.iosCanBeUseSystemBrowser, newVal);
  }

  updateIOSCanBeUseSystemBrowser() {
    var val =
        getSettingAsKeyIdent<bool>(SettingsAllKey.iosCanBeUseSystemBrowser);
    iosCanBeUseSystemBrowser = val;
  }

  bool _isNsfw = false;

  bool _macosPlayUseIINA = false;

  bool get macosPlayUseIINA {
    return _macosPlayUseIINA;
  }

  set macosPlayUseIINA(bool newVal) {
    _macosPlayUseIINA = newVal;
    update();
    updateSetting(SettingsAllKey.macosPlayUseIINA, newVal);
  }

  bool get isNsfw {
    return _isNsfw;
  }

  set isNsfw(newVal) {
    _isNsfw = newVal;
    _mirrorIndex = 0;
    update();
    updateSetting(SettingsAllKey.isNsfw, newVal);
  }

  int get mirrorIndex {
    if (_cacheMirrorIndex == -1) {
      return getSettingAsKeyIdent<int>(SettingsAllKey.mirrorIndex);
    }
    return _cacheMirrorIndex;
  }

  set mirrorIndex(int newVal) {
    updateSetting(SettingsAllKey.mirrorIndex, newVal);
  }

  set _mirrorIndex(int newVal) {
    mirrorIndex = newVal;
    _cacheMirrorIndex = newVal;
    searchBarController.clear();
    currentCategoryerNow = null;
    update();
    updateHomeData(
      isFirst: true,
    );
  }

  /// 清理缓存
  /// => 重启之后部分设置才会生效
  easyCleanCacheHook() {
    _isNsfw = false;
    _cacheMirrorIndex = -1;
    mirrorCategoryPool.clean();
    if (_parseVipList.isNotEmpty) {
      _parseVipList = [];
      update();
    }
  }

  /// -1 = 未初始化
  /// >= 0 = 初始化好的值
  int _cacheMirrorIndex = -1;

  /// 删除单个源之后需要手动的设置 [mirrorIndex]
  ///
  /// 如果是在源之前的, 则 [index] = [mirrorIndex] - 1
  ///
  /// 如果是在源之后, 则 [index] = [mirrorIndex]
  removeMirrorItemSync(MovieImpl item) {
    var _index = mirrorList.indexOf(item);
    if (_index == -1) return;
    var _oldIndex = mirrorIndex;
    var _afterIndex = _oldIndex;
    if (_index < _oldIndex) {
      _afterIndex = _oldIndex - 1;
    }
    mirrorIndex = _afterIndex;
    _cacheMirrorIndex = _afterIndex;
    update();
  }

  updateMirrorIndex(int index) {
    _mirrorIndex = index;
  }

  MovieImpl get currentMirrorItem {
    return mirrorList[mirrorIndex];
  }

  bool get mirrorListIsEmpty {
    return mirrorList.isEmpty;
  }

  List<MovieImpl> get mirrorList {
    if (isNsfw) return MirrorManage.data;
    return MirrorManage.data.where((e) => !e.isNsfw).toList();
  }

  int page = 1;
  int limit = 10;

  List<MirrorOnceItemSerialize> homedata = [];

  bool isLoading = true;

  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  showMirrorModel(BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: Get.height * .92,
        width: double.infinity,
        child: const MirrorTableView(),
      ),
    );
  }

  void refreshOnLoading() async {
    try {
      page++;
      update();
      await updateHomeData();
      refreshController.loadComplete();
    } catch (e) {
      refreshController.loadFailed();
    }
  }

  void refreshOnRefresh() async {
    try {
      await updateHomeData(isFirst: true, missIsLoading: true);
      refreshController.refreshCompleted();
    } catch (e) {
      refreshController.refreshFailed();
    }
  }

  double cacheMirrorTableScrollControllerOffset = 0;

  updateCacheMirrorTableScrollControllerOffset(double newVal) {
    cacheMirrorTableScrollControllerOffset = newVal;
    update();
  }

  /// 初始化滚动条坐标值
  ///
  /// 判断条件
  ///
  /// ```js
  /// (屏幕高度 - kToolbarHeight) < (_offset * 69)
  /// // - 源数量必须 >= 10
  /// // - 当前正在使用的源 >= 10
  /// ```
  ///
  /// 高度计算
  ///
  /// ```
  /// // 每个卡片 69 * index
  /// ```
  initCacheMirrorTableScrollControllerOffset() {
    double _h = Get.height - kToolbarHeight;

    double _offset = mirrorIndex * 69.0;

    bool _screenCheckFlag = _offset > _h;

    // bool _lengthCheckFlag = mirrorList.length <= 9 || mirrorIndex <= 9;
    // if (_lengthCheckFlag) return;

    if (_screenCheckFlag) {
      updateCacheMirrorTableScrollControllerOffset(_offset);
    }
  }

  initMovieParseVipList() {
    var data = parseAs.where(distinct: false).findAllSync();
    _parseVipList = data;
    update();
  }

  bool addMovieParseVip(dynamic model) {
    bool tryBetter = false;
    if (model is List<ParseIsarModel>) {
      _parseVipList.addAll(model);
      _currentParseVipIndex = 0;
      tryBetter = true;
    } else if (model is ParseIsarModel) {
      _parseVipList.insert(0, model);
      if (_parseVipList.length >= 2) {
        _currentParseVipIndex++;
      }
      tryBetter = true;
    }
    if (tryBetter) {
      update();
      isarInstance.writeTxnSync(() {
        parseAs.putAllSync(_parseVipList);
      });
    }
    return tryBetter;
  }

  removeMovieParseVipOnce(int index) {
    _parseVipList.removeAt(index);

    // TODO: 实现正确的索引而不是每次都重置
    _currentParseVipIndex = 0;

    update();

    parseAs.clearSync();
    parseAs.putAllSync(_parseVipList);
  }

  setDefaultMovieParseVipIndex(int index) {
    if (_parseVipList.length <= index) return;
    _currentParseVipIndex = index;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    updateWindowLastSize();
    WidgetsBinding.instance.addObserver(this);
    updateNsfwSetting();
    updateIOSCanBeUseSystemBrowser();
    updateMacosPlayUseIINAState();
    updateHomeData(isFirst: true);
    initCacheMirrorTableScrollControllerOffset();
    initMovieParseVipList();
  }

  updateWindowLastSize() {
    windowLastSize = View.of(Get.context!).physicalSize;
    update();
  }

  updateMacosPlayUseIINAState() {
    _macosPlayUseIINA =
        getSettingAsKeyIdent<bool>(SettingsAllKey.macosPlayUseIINA);
    update();
  }

  String indexHomeLoadDataErrorMessage = "";

  updateNsfwSetting() {
    _isNsfw = getSettingAsKeyIdent<bool>(SettingsAllKey.isNsfw);
    update();
  }

  Future<List<MirrorOnceItemSerialize>> updateSearchData(
    String keyword, {
    page = 1,
    limit = 10,
  }) async {
    var resp = await currentMirrorItem.getSearch(
      keyword: keyword,
      page: page,
      limit: limit,
    );
    return resp;
  }

  Future<String?> syncCurrentCategoryer() async {
    try {
      if (mirrorListIsEmpty) return null;
      var category = await currentMirrorItem.getCategory();

      /// NOTE(d1y): 为空也是一种错误的表现
      if (category.isEmpty) {
        mirrorCategoryPool.fetchCountPP(currentMirrorItemId);
        return null;
      }
      mirrorCategoryPool.put(currentMirrorItemId, category);
      // XXX(d1y): 默认使用全部分类
      currentCategoryerNow = kAllCategoryData;
      update();
      return kAllCategoryData.id;
    } catch (e) {
      if (currentMirrorItemId.isNotEmpty) {
        mirrorCategoryPool.fetchCountPP(currentMirrorItemId);
      }
      debugPrint(e.toString());
      return null;
    }
  }

  /// [isFirst] 初始化加载数据需要将 [isLoading] => true
  /// [missIsLoading] 某些特殊情况下不需要设置 [isLoading] => true
  updateHomeData({bool isFirst = false, missIsLoading = false}) async {
    /// 如果都没有源, 则不需要加载数据
    /// => +_+ 还玩个球啊
    if (mirrorListIsEmpty) return;

    var onceCategory = "";
    if (currentCategoryerNow != null) {
      var id = currentCategoryerNow!.id;
      onceCategory = id;
    }
    if (isFirst) {
      /// NOTE(d1y): 不存在分类并且请求次数没有超过阈值
      if (!currentHasCategoryer &&
          !mirrorCategoryPool.fetchCountAlreadyMax(currentMirrorItemId)) {
        onceCategory = await syncCurrentCategoryer() ?? "";
      }
    }

    /// XXX(d1y): 但凡是个正常一点的站点都不会用 `-114514` 作为分类的
    if (onceCategory == kAllCategoryPoint) {
      onceCategory = "";
    }

    /// 如果 [indexHomeLoadDataErrorMessage] 错误栈有内容的话
    /// 并且 [isFirst] 不是初始化数据的话, 就不允许加载更多
    if (indexHomeLoadDataErrorMessage != "" && !isFirst) return;

    try {
      if (isFirst) {
        EasyLoading.show( // 缓存过不需要加载动画🤡
          status: "加载中",
          indicator: Image.asset(
            "assets/loading.gif",
            width: 120,
            height: 120,
          ),
        );
        isLoading = !missIsLoading;
        page = 1;
        update();
      }
      debugPrint("handle axaj get page: $page, $limit");
      List<MirrorOnceItemSerialize> data = await currentMirrorItem.getHome(
        page: page,
        limit: limit,
        category: onceCategory,
      );
      if (isFirst) {
        homedata = data;
      } else {
        homedata.addAll(data);
      }
      indexHomeLoadDataErrorMessage = "";
      update();
    } catch (e) {
      indexHomeLoadDataErrorMessage = e.toString();
      homedata = [];
      update();
    } finally {
      isLoading = false;
      EasyLoading.dismiss();
    }

    String id = currentMirrorItem.meta.id;
    bool notError = indexHomeLoadDataErrorMessage == "";

    // NOTE: 只会在 [isFirst] 后存入持久化缓存
    MirrorStatusStack().pushStatus(
      id,
      notError,
      canSave: isFirst,
    );
  }

  @override
  void onReady() {
    refreshController = RefreshController();
    super.onReady();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    updateWindowLastSize();
  }

  void changeCurrentBarIndex(int i) {
    // debugPrint("next index: $i, current index: $currentBarIndex");

    if (currentBarIndex == i) return;

    // NOTE:
    // => 之前为了实现所谓的动画
    // => 如果 currentBarIndex - i 绝对值不是 1 的话, 就不会有动画
    // => 但是这动画看起来真的太生硬了
    // => 2022年/05月/14日 14:51
    // int absVal = currentBarIndex - i;
    // currentBarIndex = i;
    // var val = absVal.abs();
    // if (val >= 2) {
    //   currentBarController.jumpToPage(
    //     i,
    //   );
    // } else {
    //   currentBarController.animateToPage(
    //     i,
    //     curve: Curves.ease,
    //     duration: Duration(milliseconds: 500),
    //   );
    // }

    currentBarIndex = i;
    currentBarController.jumpToPage(
      i,
    );

    update();
  }

  final SearchBarController<MirrorOnceItemSerialize> searchBarController =
      SearchBarController<MirrorOnceItemSerialize>();
}
