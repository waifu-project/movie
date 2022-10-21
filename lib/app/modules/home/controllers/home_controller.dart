// Copyright (C) 2021-2022 d1y <chenhonzhou@gmail.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'package:flappy_search_bar_ns/flappy_search_bar_ns.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:movie/app/modules/home/views/mirrortable.dart';
import 'package:movie/app/shared/mirror_category.dart';
import 'package:movie/app/shared/mirror_status_stack.dart';
import 'package:movie/config.dart';
import 'package:movie/impl/movie.dart';
import 'package:movie/mirror/mirror.dart';
import 'package:movie/mirror/mirror_serialize.dart';
import 'package:movie/models/movie_parse.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

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
  List<MovieParseModel> _parseVipList = [];
  int get currentParseVipIndex => _currentParseVipIndex;
  List<MovieParseModel> get parseVipList => _parseVipList;
  MovieParseModel? get currentParseVipModelData {
    if (parseVipList.length <= 0 ||
        currentParseVipIndex >= parseVipList.length) {
      return null;
    }
    return parseVipList[currentParseVipIndex];
  }

  final localStorage = GetStorage();

  final mirrorCategoryPool = MirrorCategoryPool();

  String get currentMirrorItemId {
    if (mirrorListIsEmpty) return "";
    return currentMirrorItem.meta.id;
  }

  /// `ios` 播放视频是否使用默认的系统浏览器
  /// 1. 浏览器默认支持: `m3u8` | `mp4`
  /// 2. 网页可以直接跳转给浏览器用
  /// (所以`ios`默认直接走浏览器岂不美哉?)
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
    localStorage.write(ConstDart.iosVideoSystemBrowser, newVal);
  }

  updateIOSCanBeUseSystemBrowser() {
    iosCanBeUseSystemBrowser =
        localStorage.read<bool>(ConstDart.iosVideoSystemBrowser) ?? true;
  }

  bool _isNsfw = false;

  bool _macosPlayUseIINA = false;

  bool get macosPlayUseIINA {
    return _macosPlayUseIINA;
  }

  set macosPlayUseIINA(bool newVal) {
    _macosPlayUseIINA = newVal;
    update();
    localStorage.write(ConstDart.macosPlayUseIINA, newVal);
  }

  bool get isNsfw {
    return _isNsfw;
  }

  set isNsfw(newVal) {
    _isNsfw = newVal;
    _mirrorIndex = 0;
    update();
    localStorage.write(ConstDart.is_nsfw, newVal);
  }

  int get mirrorIndex {
    if (_cacheMirrorIndex == -1)
      return localStorage.read(ConstDart.ls_mirrorIndex) ?? 0;
    return _cacheMirrorIndex;
  }

  set mirrorIndex(int newVal) {
    localStorage.write(ConstDart.ls_mirrorIndex, newVal);
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

  set _page(newVal) {
    // TODO
  }

  set _limit(newVal) {
    // TODO
  }

  List<MirrorOnceItemSerialize> homedata = [];

  bool isLoading = false;

  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  showMirrorModel(BuildContext context) {
    Get.to(
      () => MirrorTableView(),
      duration: Duration(
        milliseconds: 240,
      ),
      transition: Transition.cupertino,
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
    dynamic dataWithJson = localStorage.read(ConstDart.movieParseVip) ?? [];
    if (dataWithJson is List) {
      var models = dataWithJson
          .map(
            (e) => MovieParseModel.fromJson(e),
          )
          .toList();
      _parseVipList = models;
      update();
    }
  }

  bool addMovieParseVip(dynamic model) {
    bool tryBetter = false;
    if (model is List<MovieParseModel>) {
      _parseVipList.addAll(model);
      _currentParseVipIndex = 0;
      tryBetter = true;
    } else if (model is MovieParseModel) {
      _parseVipList.insert(0, model);
      if (_parseVipList.length >= 2) {
        _currentParseVipIndex++;
      }
      tryBetter = true;
    }
    if (tryBetter) {
      update();
      localStorage.write(ConstDart.movieParseVip, _parseVipList);
    }
    return tryBetter;
  }

  removeMovieParseVipOnce(int index) {
    _parseVipList.removeAt(index);

    // TODO: 实现正确的索引而不是每次都重置
    _currentParseVipIndex = 0;

    update();
    localStorage.write(ConstDart.movieParseVip, _parseVipList);
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
    windowLastSize = WidgetsBinding.instance.window.physicalSize;
    update();
  }

  updateMacosPlayUseIINAState() {
    _macosPlayUseIINA = localStorage.read(ConstDart.macosPlayUseIINA) ?? false;
    update();
  }

  String indexHomeLoadDataErrorMessage = "";

  updateNsfwSetting() {
    _isNsfw = localStorage.read(ConstDart.is_nsfw) ?? false;
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
      if (!currentHasCategoryer && !mirrorCategoryPool.fetchCountAlreadyMax(currentMirrorItemId)) {
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
      isLoading = false;
      indexHomeLoadDataErrorMessage = "";
      update();
    } catch (e) {
      indexHomeLoadDataErrorMessage = e.toString();
      isLoading = false;
      homedata = [];
      update();
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
    refreshController = new RefreshController();
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

  final SearchBarController searchBarController =
      SearchBarController<MirrorOnceItemSerialize>();
}
