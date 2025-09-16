import 'package:catmovie/utils/boop.dart';
import 'package:command_palette/command_palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:catmovie/app/modules/home/views/mirrortable.dart';
import 'package:catmovie/app/shared/bus.dart';
import 'package:catmovie/app/shared/mirror_category.dart';
import 'package:catmovie/app/shared/mirror_status_stack.dart';
import 'package:catmovie/isar/repo.dart';
import 'package:catmovie/shared/manage.dart';
import 'package:catmovie/isar/schema/parse_schema.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import 'package:catmovie/app/extension.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xi/xi.dart';

const kSmoothListViewDuration = Duration(milliseconds: 210);

/// 历史记录处理类型
enum UpdateSearchHistoryType {
  /// 添加
  add,

  /// 删除
  remove,

  /// 清除所有
  clean
}

Widget kActivityIndicator = NutsActivityIndicator(
  tickCount: 9,
  radius: 12,
  relativeWidth: 1.24,
  inactiveColor: Colors.white.withValues(alpha: 0.42),
  activeColor: Colors.white,
);

Function showLoading(String msg) {
  EasyLoading.show(
    // status: msg,
    // indicator: Image.asset(
    //   "assets/loading.gif",
    //   width: 120,
    //   height: 120,
    // ),
    indicator: kActivityIndicator,
  );
  return EasyLoading.dismiss;
}

Future<bool> showLoadingPlaceholderTask(AsyncCallback task) async {
  var errMsg = "";
  try {
    Get.dialog(
      Center(
        // child: Image.asset(
        //   "assets/loading.gif",
        //   width: 120,
        //   height: 120,
        // ),
        child: kActivityIndicator,
      ),
    );
    await task();
  } catch (e) {
    errMsg = e.toString();
  } finally {
    Get.back();
  }
  if (errMsg.isNotEmpty) {
    EasyLoading.showError(errMsg);
    return false;
  }
  return true;
}

class HomeController extends GetxController
    with WidgetsBindingObserver, ProtocolListener {
  final FocusScopeNode focusNode = FocusScopeNode();
  final FocusNode homeFocusNode = FocusNode();

  late Size windowLastSize;

  bool showBottomNavigationBar = true;

  void setBottomNavigationBar(bool newVal) {
    showBottomNavigationBar = newVal;
    update();
  }

  var currentBarIndex = 0;

  var currentBarController = PageController(initialPage: 0, keepPage: true);

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

  final cacheCategory = CacheWithCategory();

  String get currentMirrorItemId {
    if (mirrorListIsEmpty) return "";
    return currentMirrorItem.meta.id;
  }

  List<SourceSpiderQueryCategory> get currentCategoryer {
    var data = cacheCategory.data(currentMirrorItemId);
    return data;
  }

  bool get currentHasCategoryer {
    return cacheCategory.has(currentMirrorItemId);
  }

  SourceSpiderQueryCategory? currentCategoryerNow;

  void setCurrentCategoryerNow(SourceSpiderQueryCategory category) {
    currentCategoryerNow = category;
    cacheCategory.setLastUsed(currentMirrorItem.meta.id, category);
    updateHomeData(isFirst: true);
    update();
  }

  bool _isNsfw = false;

  bool get isNsfw {
    return _isNsfw;
  }

  set isNsfw(bool newVal) {
    _isNsfw = newVal;
    _mirrorIndex = 0;
    update();
    updateSetting(SettingsAllKey.isNsfw, newVal);
  }

  int get mirrorIndex {
    if (_cacheMirrorIndex == -1) {
      try {
        // 这里在清除缓存时会抛出索引异常, 主要是取 settingsSingleModel 取不到了
        return getSettingAsKeyIdent<int>(SettingsAllKey.mirrorIndex);
      } catch (e) {
        // workaround: 因为有内置源的存在, 所以这里设置为 0 是不会出错的
        return 0;
      }
    }
    return _cacheMirrorIndex;
  }

  set mirrorIndex(int newVal) {
    updateSetting(SettingsAllKey.mirrorIndex, newVal);
  }

  set _mirrorIndex(int newVal) {
    if (newVal >= mirrorList.length) {
      // 如果新设置的索引大于 mirrorList 的长度的话, 则默认设置为 0
      newVal = 0;
    }
    mirrorIndex = newVal;
    _cacheMirrorIndex = newVal;
    currentCategoryerNow = null;
    update();
    updateHomeData(
      isFirst: true,
    );
  }

  /// 清理缓存
  /// => 重启之后部分设置才会生效
  void easyCleanCacheHook() {
    _isNsfw = false;
    _cacheMirrorIndex = -1;
    cacheCategory.clean();
    cacheCategory.cleanupLastUsed();
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
  void removeMirrorItemSync(ISpiderAdapter item) {
    var index = mirrorList.indexOf(item);
    if (index == -1) return;
    var oldIndex = mirrorIndex;
    var afterIndex = oldIndex;
    if (index < oldIndex) {
      afterIndex = oldIndex - 1;
    }
    mirrorIndex = afterIndex;
    _cacheMirrorIndex = afterIndex;
    update();
  }

  void updateMirrorIndex(int index) {
    _mirrorIndex = index;
  }

  ISpiderAdapter get currentMirrorItem {
    if (mirrorIndex <= mirrorList.length - 1) {
      // 也有可能是 -1 吗?
      if (mirrorIndex == -1) return EmptySpiderAdapter();
      return mirrorList[mirrorIndex];
    }
    return EmptySpiderAdapter();
  }

  bool get mirrorListIsEmpty {
    return mirrorList.isEmpty;
  }

  List<ISpiderAdapter> get mirrorList {
    if (isNsfw) {
      return SpiderManage.data.where((e) => e.isNsfw).toList();
    }
    return SpiderManage.data.where((e) => !e.isNsfw).toList();
  }

  int page = 1;
  int limit = 10;

  List<VideoDetail> homedata = [];

  bool isLoading = true;

  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  void showMirrorModel(BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: Get.height * .88,
        width: double.infinity,
        child: const MirrorTableView(),
      ),
    );
  }

  void refreshOnLoading() async {
    boop.selection();
    try {
      page++;
      update();
      await updateHomeData();
      refreshController.loadComplete();
      boop.success();
    } catch (e) {
      refreshController.loadFailed();
      boop.error();
    }
  }

  void refreshOnRefresh() async {
    boop.selection();
    try {
      await updateHomeData(isFirst: true, missIsLoading: true);
      refreshController.refreshCompleted();
    } catch (e) {
      refreshController.refreshFailed();
    }
  }

  double cacheMirrorTableScrollControllerOffset = 0;

  void updateCacheMirrorTableScrollControllerOffset(double newVal) {
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
  void initCacheMirrorTableScrollControllerOffset() {
    double h = Get.height - kToolbarHeight;

    double offset = mirrorIndex * 69.0;

    bool screenCheckFlag = offset > h;

    // bool _lengthCheckFlag = mirrorList.length <= 9 || mirrorIndex <= 9;
    // if (_lengthCheckFlag) return;

    if (screenCheckFlag) {
      updateCacheMirrorTableScrollControllerOffset(offset);
    }
  }

  void initMovieParseVipList() {
    var data = parseAs.where(distinct: false).findAllSync();
    _parseVipList = data;
    update();
  }

  bool addMovieParseVip(dynamic model) {
    bool isOK = false;
    if (model is List<ParseIsarModel>) {
      _parseVipList.addAll(model);
      _currentParseVipIndex = 0;
      isOK = true;
    } else if (model is ParseIsarModel) {
      _parseVipList.insert(0, model);
      if (_parseVipList.length >= 2) {
        _currentParseVipIndex++;
      }
      isOK = true;
    } else if (model is List<String>) {
      var m = ParseIsarModel(model[0], model[1]);
      _parseVipList.insert(0, m);
      isOK = true;
    }
    if (isOK) {
      update();
      isarInstance.writeTxnSync(() {
        parseAs.putAllSync(_parseVipList);
      });
    }
    return isOK;
  }

  void removeMovieParseVipOnce(int index) {
    _parseVipList.removeAt(index);

    // TODO: 实现正确的索引而不是每次都重置
    _currentParseVipIndex = 0;

    update();

    parseAs.clearSync();
    parseAs.putAllSync(_parseVipList);
  }

  void setDefaultMovieParseVipIndex(int index) {
    if (_parseVipList.length <= index) return;
    _currentParseVipIndex = index;
    update();
  }

  @override
  void onInit() {
    protocolHandler.addListener(this);
    updateWindowLastSize();
    WidgetsBinding.instance.addObserver(this);
    cacheCategory.init();
    updateNsfwSetting();
    updateHomeData(isFirst: true);
    initCacheMirrorTableScrollControllerOffset();
    initMovieParseVipList();
    super.onInit();
  }

  void updateWindowLastSize() {
    windowLastSize = View.of(Get.context!).physicalSize;
    update();
  }

  String indexHomeLoadDataErrorMessage = "";

  void updateNsfwSetting() {
    _isNsfw = getSettingAsKeyIdent<bool>(SettingsAllKey.isNsfw);
    update();
  }

  Future<SourceSpiderQueryCategory?> syncCurrentCategoryer() async {
    try {
      if (mirrorListIsEmpty) return null;
      var category = await currentMirrorItem.getCategory();

      // NOTE(d1y): 为空也是一种错误的表现
      if (category.isEmpty) {
        cacheCategory.fetchCountPP(currentMirrorItemId);
        return null;
      }
      cacheCategory.put(currentMirrorItemId, category);
      currentCategoryerNow = category.first;
      update();
      return category.first;
    } catch (e) {
      if (currentMirrorItemId.isNotEmpty) {
        cacheCategory.fetchCountPP(currentMirrorItemId);
      }
      debugPrint(e.toString());
      return null;
    }
  }

  /// [isFirst] 初始化加载数据需要将 [isLoading] => true
  /// [missIsLoading] 某些特殊情况下不需要设置 [isLoading] => true
  Future<void> updateHomeData(
      {bool isFirst = false, missIsLoading = false}) async {
    /// 如果都没有源, 则不需要加载数据
    /// => +_+ 还玩个球啊
    if (mirrorListIsEmpty) return;

    var onceCategory = "";
    if (currentCategoryerNow != null) {
      onceCategory = currentCategoryerNow!.id;
    }
    if (isFirst) {
      var dispose = showLoading("加载分类中");

      // NOTE(d1y): 不存在分类并且请求次数没有超过阈值
      var needFetch = !currentHasCategoryer &&
          !cacheCategory.fetchCountAlreadyMax(currentMirrorItemId);

      if (needFetch) {
        try {
          var category = (await syncCurrentCategoryer()) ?? kDefaultAllCategory;
          onceCategory = category.id;
        } catch (e) {
          debugPrint(e.toString());
        } finally {
          dispose();
        }
      } else {
        var lastUsed = cacheCategory.getLastUsed(currentMirrorItem.meta.id);
        if (lastUsed != null) {
          currentCategoryerNow = lastUsed;
          update();
        }
        if (currentCategoryerNow == null) {
          currentCategoryerNow = currentCategoryer.first;
          update();
        }
        onceCategory = currentCategoryerNow!.id;
      }
    }

    /// 如果 [indexHomeLoadDataErrorMessage] 错误栈有内容的话
    /// 并且 [isFirst] 不是初始化数据的话, 就不允许加载更多
    if (indexHomeLoadDataErrorMessage != "" && !isFirst) return;

    try {
      if (isFirst) {
        showLoading("加载内容中");
        isLoading = !missIsLoading;
        page = 1;
        update();
      }
      debugPrint("get home data: $page, $limit");
      List<VideoDetail> data = await currentMirrorItem.getHome(
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
    protocolHandler.removeListener(this);
  }

  @override
  void didChangeMetrics() {
    updateWindowLastSize();
  }

  void switchTabview(TabSwitchDirection direction) {
    if (currentBarIndex == 0 && direction == TabSwitchDirection.left) return;
    if (currentBarIndex == 2 && direction == TabSwitchDirection.right) return;
    if (direction == TabSwitchDirection.left) {
      currentBarIndex--;
    } else {
      currentBarIndex++;
    }
    currentBarController.jumpToPage(currentBarIndex);
    update();
  }

  void changeCurrentBarIndex(int i) {
    if (currentBarIndex == i) return;
    currentBarIndex = i;
    // ignore: dead_code
    if (GetPlatform.isDesktop && false) {
      // 这个动画好悬没给我眼睛看花了
      int absVal = currentBarIndex - i;
      var val = absVal.abs();
      if (val >= 2) {
        currentBarController.jumpToPage(i);
      } else {
        currentBarController.animateToPage(
          i,
          curve: Curves.ease,
          duration: const Duration(milliseconds: 120),
        );
      }
    } else {
      currentBarController.jumpToPage(i);
    }
    boop.selection();
    update();
  }

  void clearCache() async {
    SpiderManage.cleanAll();
    easyCleanCacheHook();
    IsarRepository().safeWrite(() {
      isarInstance.clearSync();
    });
  }

  bool _isProtocolUrlReceived = false;

  /// unstable method
  ///
  /// 嘛钱不钱的，乐呵乐呵得了。
  /// ![mmp](http://k.sinaimg.cn/n/translate/288/w662h426/20190916/a339-ietnfsp5148644.jpg/w700d1q75cms.jpg)
  Future<bool> confirmAlert(
    String content, {
    BuildContext? context,
    showCancel = true,
    title = "提示",
    cancelText = "取消",
    confirmText = "确认",
  }) async {
    late BuildContext cx;
    if (context != null) {
      cx = context;
    } else {
      // 怎么可能为空? 我觉得这是一种自信
      // https://steamcommunity.com/sharedfiles/filedetails/?id=2899834211
      cx = Get.context!;
    }
    var flag = await showCupertinoDialog<bool>(
      context: cx,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <CupertinoDialogAction>[
            if (showCancel)
              CupertinoDialogAction(
                child: Text(
                  cancelText,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(ctx).pop(true);
              },
              child: Text(confirmText),
            )
          ],
        );
      },
    );
    if (flag == null || !flag) return false;
    return true;
  }

  @override
  onProtocolUrlReceived(String url) async {
    if (GetPlatform.isDesktop) {
      await windowManager.show();
      await windowManager.focus();
    }
    // https://github.com/waifu-project/movie/pull/50
    if (_isProtocolUrlReceived) return;
    _isProtocolUrlReceived = true;
    var cx = Uri.tryParse(url);
    if (cx == null) return;
    var authority = cx.authority;
    var qs = cx.queryParameters;
    var realURL = qs["url"] ?? "";
    if (realURL.isNotEmpty) {
      realURL = decodeURL(realURL);
    }
    switch (authority) {
      // yoyo://import?name=非凡资源&url=http://api.ffzyapi.com/api.php/provide/vod/at/xml&nsfw=false
      // yoyo://import?name=卧龙&url=https://collect.wolongzyw.com/api.php/provide/vod/at/json&nsfw=false
      case "import":
        String name = qs["name"] ?? "";
        late bool nsfw;
        var $qs = qs["nsfw"] ?? "false";
        if ($qs == "true") {
          nsfw = true;
        } else {
          nsfw = false;
        }
        var $url = Uri.parse(realURL);
        var msg = "将添加视频源\n名称: $name\n源地址: $realURL\n类型: ${nsfw ? '18+' : '-'}";
        var flag = await confirmAlert(msg);
        if (!flag) break;
        var $id = Xid().toString();
        var cms = MacCMSSpider(
          name: name,
          nsfw: nsfw,
          root_url: $url.origin,
          api_path: $url.path,
          id: $id,
        );
        if (!SpiderManage.addItem(cms)) {
          await confirmAlert(
            "源已经存在了, 无法添加",
            showCancel: false,
            confirmText: "我知道了",
          );
          break;
        }
        await confirmAlert(
          "视频源添加成功",
          showCancel: false,
          confirmText: "我知道了",
        );

        /// [SpiderManage.data] 中的顺序是 <扩展 + 内建>
        /// 所以当添加了源之后, 如果只有一个源的话(即当前添加的), 需要手动刷新一下
        if (SpiderManage.extend.length == 1) {
          updateHomeData(isFirst: true);
        }
        break;
      // yoyo://reset
      case "reset":
        var flag = await confirmAlert("重置后将清空缓存, 包括视频源和一些设置");
        if (!flag) break;
        clearCache();
        await confirmAlert(
          "已删除缓存, 部分内容重启之后生效!",
          showCancel: false,
          confirmText: "我知道了",
        );
        if (SpiderManage.extend.isEmpty) {
          updateHomeData(isFirst: true);
        }
        break;
      // yoyo://sub?url=https://cdn.jsdelivr.net/gh/waifu-project/v1@latest/yoyo.json
      // yoyo://sub?url=https://raw.githubusercontent.com/hd9211/Tvbox1/main/zy.json
      case "sub":
        if (realURL.isEmpty || Uri.tryParse(realURL) == null) {
          break; // TODO: need show error toast
        }
        var flag = await confirmAlert("将添加订阅源: $realURL");
        if (!flag) break;
        List<String> text =
            getSettingAsKeyIdent(SettingsAllKey.mirrorTextarea).split("\n");
        if (text.contains(realURL)) {
          await confirmAlert(
            "该订阅源已存在!",
            showCancel: false,
            confirmText: "我知道",
          );
          break;
        }
        text.add(realURL);
        var newText = text.join("\n");
        updateSetting(SettingsAllKey.mirrorTextarea, newText);
        await confirmAlert(
          "已添加订阅源, 添加之后请在 设置->视频源 更新配置",
          showCancel: false,
          confirmText: "我知道了",
        );
        break;
      // yoyo://jiexi?name=云解析&url=https://yparse.ik9.cc/index.php?url=
      case "jiexi":
        var name = qs['name'] ?? "";
        if (realURL.isEmpty || Uri.tryParse(realURL) == null || name.isEmpty) {
          break;
        }
        var flag = await confirmAlert("将添加解析源: $realURL");
        if (!flag) break;
        List<String> model = [name, realURL];
        // 默认添加到 0 位置, 但还是需要手动设置默认才行!
        if (!addMovieParseVip(model)) {
          // 理论上不可能哈
        }
        await confirmAlert(
          "已添加解析源, 要启用请在 设置->解析源管理中 更新配置",
          showCancel: false,
          confirmText: "我知道了",
        );
        break;
      // yoyo://nsfw?enable=1
      case "nsfw":
        int nsfw = int.tryParse(qs["enable"] ?? "") ?? 0;
        var enable = nsfw == 1;
        var flag = await confirmAlert("将${enable ? '开启' : '关闭'}nsfw设置");
        if (!flag) break;
        isNsfw = enable;
        $bus.fire(SettingEvent(nsfw: enable));
        break;
      // case "search":
      default:
        confirmAlert(
          "未知协议: $authority",
          showCancel: false,
          confirmText: "我知道了",
        );
    }
    _isProtocolUrlReceived = false;
  }
}
