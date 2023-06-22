import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart'
    as extend_search_bar;
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:movie/app/extension.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/routes/app_pages.dart';
import 'package:movie/app/widget/helper.dart';
import 'package:movie/app/widget/k_empty_mirror.dart';
import 'package:movie/app/widget/k_error_stack.dart';
import 'package:movie/app/widget/k_pagination.dart';
import 'package:movie/app/widget/k_tag.dart';
import 'package:movie/app/widget/window_appbar.dart';
import 'package:movie/isar/schema/history_schema.dart';
import 'package:movie/mirror/mirror_serialize.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with AutomaticKeepAliveClientMixin {
  final HomeController home = Get.find<HomeController>();

  extend_search_bar.SearchBarController<MirrorOnceItemSerialize> get _searchBarController =>
      home.searchBarController;

  List<String> _searchHistory = [];

  List<String> get searchHistory {
    return _searchHistory;
  }

  set searchHistory(List<String> newVal) {
    setState(() {
      _searchHistory = newVal;
    });
    isarInstance.writeTxnSync(() async {
      final data = newVal.map((e) => HistoryIsarModel(e)).toList();
      historyAs.clearSync();
      historyAs.putAllSync(data);
    });
  }

  loadSearchHistory() async {
    var data = historyAs.where(distinct: false).findAllSync();
    setState(() {
      _searchHistory = data.map((e) => e.content).toList();
    });
  }

  @override
  void initState() {
    loadSearchHistory();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 操作历史记录
  handleUpdateSearchHistory(
    String text, {
    type = UpdateSearchHistoryType.add,
  }) {
    var oldData = _searchHistory; // TODO: 使用 isar 中的增删改查, 而不是自己去实现这个逻辑👀
    switch (type) {
      case UpdateSearchHistoryType.add: // 添加
        oldData.remove(text);
        oldData.insert(0, text);
        break;
      case UpdateSearchHistoryType.remove: // 删除单个
        oldData.remove(text);
        break;
      case UpdateSearchHistoryType.clean: // 清除所有
        oldData = [];
        break;
      default:
    }
    searchHistory = oldData;
  }

  int _page = 1;

  int get page => _page;

  set page(int newVal) {
    setState(() {
      _page = newVal;
    });
    if (newVal == textEditingControllerIntValue) return;
    changeTextEditingController(newVal);
  }

  int limit = 20;

  int cacheDataLength = 10;

  bool isTriggerSearch = false;

  String cacheSearchText = "";

  TextEditingController textEditingController =
      TextEditingController(text: "1");

  changeTextEditingController(int text) {
    textEditingController.text = text.toString();
  }

  int get textEditingControllerIntValue =>
      int.parse(textEditingController.text);

  /// 默认 `logo`
  String get _defaultLogo => home.currentMirrorItem.meta.logo;

  bool get showEmptyStack {
    return home.mirrorListIsEmpty;
  }

  PreferredSizeWidget? get _appBar {
    bool isDesktop = GetPlatform.isDesktop;
    if (isDesktop) {
      return const WindowAppBar(
        centerTitle: true,
        title: Text(
          "搜索",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      );
    }
    return null;
  }

  double get _kEmptyMirrorWidth {
    var width = home.windowLastSize.width;
    if (width >= 500) return 120;
    return width * .6;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<HomeController>(builder: (home) {
      return Scaffold(
        appBar: _appBar,
        body: SafeArea(
          child: Builder(builder: (context) {
            if (showEmptyStack) {
              return KEmptyMirror(
                width: _kEmptyMirrorWidth,
              );
            }
            return extend_search_bar.SearchBar<MirrorOnceItemSerialize?>(
              textStyle: TextStyle(
                color: Get.isDarkMode ? Colors.white : Colors.black,
              ),
              searchBarController: _searchBarController,
              header: Builder(builder: (context) {
                if (!canShowPagingView) return const SizedBox.shrink();
                return KPagination(
                  turnL: isPrevPage,
                  turnR: isNextPage,
                  textEditingController: textEditingController,
                  onActionTap: (KPaginationActionButtonDirection type) {
                    setState(() {
                      switch (type) {
                        case KPaginationActionButtonDirection.l:
                          page--;
                          break;
                        case KPaginationActionButtonDirection.r:
                          page++;
                          break;
                        default:
                      }
                    });
                    handleStandSearch(
                      isInit: false,
                    );
                  },
                  onJumpTap: () {
                    if (page == textEditingControllerIntValue) return;
                    setState(() {
                      page = textEditingControllerIntValue;
                    });
                    handleStandSearch();
                  },
                );
              }),
              onItemFound: (item, int index) {
                String? _targetImage = item!.smallCoverImage;

                /// 比对 [item?.smallCoverImage] 和 [_defaultLogo] 是否相等来确认是否有封面图
                bool canNotFindCover = _targetImage == _defaultLogo;

                double w = 90;

                double h = 100;

                Widget coverWidget = CachedNetworkImage(
                  imageUrl: _targetImage,
                  width: w,
                  height: h,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, progress) => Center(
                    child: CircularProgressIndicator(
                      value: progress.progress,
                    ),
                  ),
                  errorWidget: (context, error, stackTrace) => kErrorImage,
                );

                // EdgeInsets _sharkPadding = EdgeInsets.all(canNotFindCover ? 10 : 0);

                if (canNotFindCover) {
                  coverWidget = const SizedBox.shrink();
                }

                return GestureDetector(
                  onTap: () async {
                    var data = item;
                    if (item.videos.isEmpty) {
                      String id = item.id;
                      Get.dialog(
                        const Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      );
                      data = await home.currentMirrorItem.getDetail(id);
                      Get.back();
                    }
                    Get.toNamed(
                      Routes.PLAY,
                      arguments: data,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1.2,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        coverWidget,
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              item.title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              searchBarStyle: const SearchBarStyle(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(24.0),
                ),
              ),
              minimumChars: 2,
              onSearch: (String? text) {
                setState(() {
                  page = 1;
                });
                return handleSearch(text);
              },
              loader: Center(
                child: Image.asset(
                  "assets/loading.gif",
                  width: 120,
                  height: 120,
                ),
              ),
              emptyWidget: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/error.png",
                      fit: BoxFit.cover,
                      width: _kEmptyMirrorWidth,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const Text(
                      '没有找到相关视频 :(',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              onError: (error) {
                return KErrorStack(
                  msg: error.toString(),
                );
              },
              cancellationWidget: const Text("取消"),
              onCancelled: () {
                setState(() {
                  isTriggerSearch = false;
                });
              },
              searchBarPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              placeHolder: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 1,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Stack(
                            children: [
                              Positioned(
                                left: 12,
                                bottom: -6,
                                child: Container(
                                  width: 120,
                                  height: 12,
                                  color: Colors.red,
                                ),
                              ),
                              Text(
                                "搜索历史",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          IconButton(
                            tooltip: "删除所有历史记录",
                            padding: const EdgeInsets.symmetric(
                              vertical: 3,
                              horizontal: 2,
                            ),
                            onPressed: () {
                              handleUpdateSearchHistory(
                                "",
                                type: UpdateSearchHistoryType.clean,
                              );
                            },
                            icon: const Icon(CupertinoIcons.clear),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Builder(builder: (context) {
                        if (searchHistory.isEmpty) {
                          return Text(
                            "暂无历史记录",
                            style: Theme.of(context).textTheme.titleSmall,
                          );
                        }
                        return Wrap(
                          children: searchHistory
                              .map(
                                (e) => KTag(
                                  child: Text(e),
                                  backgroundColor: Get.isDarkMode
                                      ? Colors.black26
                                      : Colors.black12,
                                  onTap: (type) {
                                    switch (type) {
                                      case KTagTapEventType.content: // 内容
                                        handleUpdateSearchHistory(
                                          e,
                                          type: UpdateSearchHistoryType.add,
                                        );
                                        handleStandSearch(title: e);
                                        break;
                                      case KTagTapEventType.action: // action
                                        handleUpdateSearchHistory(
                                          e,
                                          type: UpdateSearchHistoryType.remove,
                                        );
                                        break;
                                      default:
                                    }
                                  },
                                ),
                              )
                              .toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  /// [isInit] 是否是初始化, 将 [page] => 1
  ///
  /// [title] 如果未设置内容默认走缓存 [cacheSearchText]
  handleStandSearch({
    String? title,
    bool isInit = true,
  }) {
    if (isInit) {
      setState(() {
        page = 1;
      });
    }
    var outputTitle = cacheSearchText;
    if (title != null) outputTitle = title;
    return _searchBarController.injectSearch(
      outputTitle,
      handleSearch,
    );
  }

  /// 由于 [MovieImpl] 接口类返回的数据是一个 [List<MirrorOnceItemSerialize>]
  /// 所以无法获取到是否还有下一页, 只有通过判断其是否是整数
  /// [ 10, 20 ] (此处传递的 [limit] 参数无效)
  bool get isNextPage {
    return [10, 20].any((element) => element == cacheDataLength);
  }

  bool get isPrevPage {
    return page >= 2;
  }

  bool get canShowPagingView {
    return (isNextPage || isPrevPage) && isTriggerSearch;
  }

  /// 默认就初始化为 [page]
  /// [isInitPage]
  Future<List<MirrorOnceItemSerialize>> handleSearch(String? text) async {
    try {
      if (text == null) return [];
      setState(() {
        isTriggerSearch = true;
        cacheSearchText = text;
      });
      handleUpdateSearchHistory(
        text,
        type: UpdateSearchHistoryType.add,
      );
      var data = await home.updateSearchData(text, page: page, limit: limit);
      setState(() {
        cacheDataLength = data.length;
      });
      return data;
    } on DioError catch (dioError) {
      setState(() {
        isTriggerSearch = false;
      });
      throw AsyncError(
        dioError,
        StackTrace.fromString(
          dioError.error.toString(),
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
