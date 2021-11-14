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

  bool _isNsfw = false;

  bool get isNsfw {
    return _isNsfw;
  }

  set isNsfw(newVal) {
    _mirrorIndex = 0;
    _isNsfw = newVal;
    update();
    localStorage.write(ConstDart.is_nsfw, newVal);
  }

  int get mirrorIndex {
    return localStorage.read(ConstDart.ls_mirrorIndex) ?? 0;
  }

  set mirrorIndex(int newVal) {
    localStorage.write(ConstDart.ls_mirrorIndex, newVal);
  }

  set _mirrorIndex(int newVal) {
    mirrorIndex = newVal;
    update();
    updateHomeData(
      isFirst: true,
    );
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
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => MirrorTableView(),
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

  @override
  void onInit() {
    super.onInit();
    updateWindowLastSize();
    WidgetsBinding.instance!.addObserver(this);
    updateNsfwSetting();
    updateHomeData(isFirst: true);
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

  Future<List<MirrorOnceItemSerialize>> updateSearchData(String keyword) async {
    var resp = await currentMirrorItem.getSearch(keyword: keyword);
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
