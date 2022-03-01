// Copyright (C) 2021 d1y <chenhonzhou@gmail.com>
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:movie/app/modules/home/views/mirrortable.dart';
import 'package:movie/config.dart';
import 'package:movie/impl/movie.dart';
import 'package:movie/mirror/mirror.dart';
import 'package:movie/mirror/mirror_serialize.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

  final localStorage = GetStorage();

  /// `ios` 播放视频是否使用默认的系统浏览器
  /// 1. 浏览器默认支持: `m3u8` | `mp4`
  /// 2. 网页可以直接跳转给浏览器用
  /// (所以`ios`默认直接走浏览器岂不美哉?)
  bool _iosCanBeUseSystemBrowser = true;

  bool get iosCanBeUseSystemBrowser =>
      _iosCanBeUseSystemBrowser && GetPlatform.isIOS;

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
    update();
    updateHomeData(
      isFirst: true,
    );
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
    Get.to(() => MirrorTableView(),
        duration: Duration(
          microseconds: 420,
        ));
    // showCupertinoModalBottomSheet(
    //   context: context,
    //   builder: (context) => MirrorTableView(),
    // );
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

  @override
  void onInit() {
    super.onInit();
    updateWindowLastSize();
    WidgetsBinding.instance!.addObserver(this);
    updateNsfwSetting();
    updateIOSCanBeUseSystemBrowser();
    updateHomeData(isFirst: true);
    initCacheMirrorTableScrollControllerOffset();
  }

  updateWindowLastSize() {
    windowLastSize = WidgetsBinding.instance!.window.physicalSize;
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

  /// [isFirst] 初始化加载数据需要将 [isLoading] => true
  /// [missIsLoading] 某些特殊情况下不需要设置 [isLoading] => true
  updateHomeData({bool isFirst = false, missIsLoading = false}) async {
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
  }

  @override
  void onReady() {
    refreshController = new RefreshController();
    super.onReady();
  }

  @override
  void onClose() {
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    updateWindowLastSize();
  }

  void changeCurrentBarIndex(int i) {
    if (currentBarIndex == i) return;
    int absVal = currentBarIndex - i;
    currentBarIndex = i;
    var val = absVal.abs();
    if (val >= 2) {
      currentBarController.jumpToPage(
        i,
      );
    } else {
      currentBarController.animateToPage(
        i,
        curve: Curves.ease,
        duration: Duration(milliseconds: 500),
      );
    }
    update();
  }
}
