import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/routes/app_pages.dart';
import 'package:catmovie/app/widget/helper.dart';
import 'package:catmovie/app/widget/k_tag.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:catmovie/isar/schema/history_schema.dart';
import 'package:catmovie/utils/boop.dart';
import 'package:concurrent_queue/concurrent_queue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/extension.dart';
import 'package:isar/isar.dart';
import 'package:tuple/tuple.dart';
import 'package:xi/xi.dart';

final kAllSourceMeta = SourceItemMeta(id: "6324", name: "全部", domain: "empty");

final int kDefaultPagingSize = 20;

typedef MapVideosRecord = Tuple2<SourceItemMeta, List<VideoDetail>>;

class SearchV2 extends StatefulWidget {
  const SearchV2({super.key});

  @override
  State<SearchV2> createState() => _SearchV2State();
}

class _SearchV2State extends State<SearchV2> with AfterLayoutMixin {
  final home = Get.find<HomeController>();

  Map<SourceItemMeta, List<VideoDetail>> map = {};

  // [int]  -> 当前 page-size
  // [bool] -> 是否有更多视频
  Map<SourceItemMeta, Tuple2<int, bool>> pagingMap = {};

  TextEditingController textEditingController = TextEditingController();

  String keyword = "";

  bool isSearching = false;

  bool showHistory = true;

  List<String> _searchHistory = [];

  List<String> get searchHistory {
    return _searchHistory;
  }

  set searchHistory(List<String> newVal) {
    setState(() {
      _searchHistory = newVal;
    });
  }

  SourceItemMeta currSource = kAllSourceMeta;

  List<SourceItemMeta> get sourceList {
    var result = map.keys.toList();
    result = result.where((item) {
      return (map[item] ?? []).isNotEmpty;
    }).toList();
    if (result.isNotEmpty) {
      result.insert(
        0,
        kAllSourceMeta,
      );
    }
    return result;
  }

  List<VideoDetail> get videos {
    if (currSource == kAllSourceMeta) {
      return map.values.expand((e) => e).toList();
    }
    return map[currSource] ?? [];
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    searchFocusNode.addListener(() {
      if (mounted) _hasFocus = searchFocusNode.hasFocus;
      setState(() {});
    });
    loadSources();
    loadSearchHistory();
    scrollController.addListener(() {
      if (currSource == kAllSourceMeta) return;
      var cx = pagingMap[currSource];
      if (cx == null || !cx.item2) return;
      double currentPosition = scrollController.position.pixels;
      double maxScrollExtent = scrollController.position.maxScrollExtent;
      if (currentPosition >= maxScrollExtent - 1) {
        // debugPrint("已经滚动到底部");
        showMoreBtn = true;
        if (mounted) setState(() {});
      }
      if (currentPosition > _lastScrollPosition) {
        // debugPrint("向下滚动");
      } else if (currentPosition < _lastScrollPosition) {
        // debugPrint("向上滚动");
        showMoreBtn = false;
        if (mounted) setState(() {});
      }
      _lastScrollPosition = currentPosition;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchFocusNode.dispose();
    scrollController.dispose();
    stopSearch();
  }

  final queue = ConcurrentQueue(concurrency: 3);
  bool searchDone = false;
  bool showMoreBtn = false;
  bool moreBtnLoading = false;

  // 记录上一次滚动位置
  double _lastScrollPosition = 0;

  List<ISpiderAdapter> sources = [];

  ScrollController scrollController = ScrollController();

  FocusNode searchFocusNode = FocusNode();
  bool _hasFocus = true;

  void stopSearch() {
    queue.pause();
    queue.clear();
  }

  void handleClean() {
    stopSearch();
    textEditingController.clear();
    keyword = "";
    showHistory = true;
    isSearching = false;
    searchDone = true;
    map.clear();
    setState(() {});
  }

  Future<void> loadSearchHistory() async {
    var data = historyAs.filter().isNsfwEqualTo(home.isNsfw).findAllSync();
    setState(() {
      _searchHistory = data.map((e) => e.content).toList();
    });
  }

  void loadSources() {
    List<ISpiderAdapter> _sources = List.from(home.mirrorList);
    _sources.remove(home.currentMirrorItem);
    _sources.insert(0, home.currentMirrorItem);
    sources = _sources;
    debugPrint("load ${sources.length} source");
    setState(() {});
  }

  void handleSearch(String _keyword) async {
    textEditingController.text = _keyword;
    showHistory = false;
    isSearching = true;
    searchDone = false;
    keyword = _keyword;
    currSource = kAllSourceMeta;
    map.clear();
    setState(() {});
    handleUpdateSearchHistory(_keyword);
    stopSearch();
    for (var item in sources) {
      queue.add<MapVideosRecord>(() async {
        var list = await item.getSearch(keyword: _keyword, page: 1, limit: 12);
        for (var video in list) {
          video.setContext(item.meta);
        }
        return Tuple2(item.meta, list);
      });
    }
    queue.on(QueueEventAction.completed, (event) {
      if (mounted) {
        var result = event.result as MapVideosRecord;
        if (result.item2.isNotEmpty) {
          map[result.item1] = result.item2;
          if (result.item2.length == kDefaultPagingSize) {
            pagingMap[result.item1] = Tuple2(1, true);
          } else {
            pagingMap[result.item1] = Tuple2(1, false);
          }
          setState(() {});
        }
      }
    });
    queue.on(QueueEventAction.idle, (event) {
      debugPrint("search done");
      if (mounted) {
        isSearching = false;
        searchDone = true;
        setState(() {});
      }
    });
    queue.start();
  }

  void handleUpdateSearchHistory(
    String text, {
    type = UpdateSearchHistoryType.add,
  }) {
    var oldData = _searchHistory;
    var nsfw = home.isNsfw;
    void safe(VoidCallback cb) {
      isarInstance.writeTxnSync(cb);
    }

    switch (type) {
      case UpdateSearchHistoryType.add: // 添加
        oldData.remove(text);
        oldData.insert(0, text);
        safe(() {
          historyAs
              .filter()
              .isNsfwEqualTo(nsfw)
              .contentEqualTo(text)
              .deleteAllSync();
          historyAs.putSync(HistoryIsarModel(nsfw, text));
        });
        break;
      case UpdateSearchHistoryType.remove: // 删除单个
        oldData.remove(text);
        safe(() {
          historyAs
              .filter()
              .isNsfwEqualTo(nsfw)
              .contentEqualTo(text)
              .deleteAllSync();
        });
        break;
      case UpdateSearchHistoryType.clean: // 清除所有
        oldData = [];
        safe(() {
          historyAs.filter().isNsfwEqualTo(nsfw).deleteAllSync();
        });
        break;
      default:
    }
    searchHistory = oldData;
  }

  Widget? _buildActionButton() {
    return (!isSearching || map.isEmpty)
        ? null
        : FloatingActionButton(
            tooltip: "停止搜索",
            onPressed: () {
              stopSearch();
              isSearching = false;
              searchDone = true;
              setState(() {});
            },
            child: const Icon(CupertinoIcons.stop_fill),
          );
  }

  PreferredSizeWidget _buildAppBar() {
    double top = MediaQuery.of(context).padding.top;
    double height = GetPlatform.isDesktop ? 81 : top;
    if (GetPlatform.isAndroid) {
      height *= 2;
    }
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: CustomMoveWindow(
          child: Column(
            children: [
              SizedBox(
                height: GetPlatform.isDesktop ? (kMacPaddingTop + 12) : top,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
                  child: Row(
                    spacing: 12,
                    children: [
                      // TODO(d1y): 支持选择(过滤)源
                      // Icon(Icons.filter_alt_outlined, size: 26),
                      Expanded(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.text,
                          child: CupertinoTextField(
                            controller: textEditingController,
                            onSubmitted: handleSearch,
                            textInputAction: TextInputAction.search,
                            autofocus: true,
                            focusNode: searchFocusNode,
                            showCursor: true,
                            decoration: BoxDecoration(
                              color: CupertinoDynamicColor.withBrightness(
                                color: "#f0f0f0".$color,
                                darkColor: "#1c1c1e".$color,
                              ),
                              border: Border.all(
                                color: CupertinoDynamicColor.withBrightness(
                                  color: CupertinoColors.inactiveGray,
                                  darkColor: CupertinoColors.white,
                                ).withValues(alpha: _hasFocus ? .42 : .12),
                                width: 1,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            onChanged: (_keyword) {
                              keyword = _keyword;
                              setState(() {});
                            },
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            style: TextStyle(
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            placeholder: "搜索",
                            prefix: Padding(
                              padding: EdgeInsets.only(
                                left: 6,
                              ),
                              child: Icon(
                                CupertinoIcons.search,
                                size: 21,
                                color: "#707070".$color,
                              ),
                            ),
                            suffix: keyword.isEmpty
                                ? null
                                : Zoom(
                                    onTap: handleClean,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: "#d0d0d0"
                                              .$color
                                              .withValues(alpha: .42),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: EdgeInsets.all(6),
                                        child: Icon(
                                          CupertinoIcons.clear,
                                          size: 12,
                                          weight: 12,
                                          color: (Get.isDarkMode
                                                  ? '#f0f0f0'
                                                  : '#1c1c1e')
                                              .$color,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Zoom(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Text(
                            "取消",
                            style: TextStyle(
                              color: CupertinoDynamicColor.withBrightness(
                                  color: '#767a82'.$color,
                                  darkColor: '#6f737a'.$color),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    String textColor = context.isDarkMode ? '#6f737a' : '#767a82';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/loading.gif",
            width: 120,
            height: 120,
          ),
          SizedBox(height: 12),
          Text("搜索中..", style: TextStyle(color: textColor.$color)),
          SizedBox(height: context.mediaQuerySize.height * .24),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    String textColor = context.isDarkMode ? '#6f737a' : '#767a82';
    return Center(
      child: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/error.png", width: 120, height: 120),
          Text(
            "没有找到相关内容",
            style: TextStyle(color: textColor.$color),
          ),
          SizedBox(height: context.mediaQuery.size.height * .24),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return Column(
      spacing: 6,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: searchHistory.isEmpty
                    ? EdgeInsets.symmetric(vertical: 5)
                    : EdgeInsets.zero,
                child: Text(
                  "搜索历史",
                  style: TextStyle(
                      fontSize: 21,
                      color: Get.isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              if (searchHistory.isNotEmpty)
                Zoom(
                  child: IconButton(
                    iconSize: 18,
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
                      boop.warning();
                    },
                    icon: const Icon(CupertinoIcons.trash),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 6,
                children: searchHistory
                    .map(
                      (_keyword) => Zoom(
                        child: KTag(
                          backgroundColor:
                              (Get.isDarkMode ? '#1f2122' : '#dfe2e4').$color,
                          onTap: (type) {
                            switch (type) {
                              case KTagTapEventType.content: // 内容
                                handleUpdateSearchHistory(
                                  _keyword,
                                  type: UpdateSearchHistoryType.add,
                                );
                                keyword = _keyword;
                                setState(() {});
                                handleSearch(keyword);
                                boop.selection();
                                break;
                              case KTagTapEventType.action: // 操作
                                handleUpdateSearchHistory(
                                  _keyword,
                                  type: UpdateSearchHistoryType.remove,
                                );
                                break;
                              default:
                            }
                          },
                          child: Text(_keyword,
                              style: TextStyle(
                                  color: Get.isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Row(
      children: [
        Container(
          width: 120,
          height: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 9),
          child: SingleChildScrollView(
            child: Column(
              spacing: 12,
              children: sourceList.map((item) {
                var textColor = Get.isDarkMode ? Colors.white : Colors.black;
                if (item == currSource) {
                  textColor = Color(0xFF6750A4);
                }
                return Zoom(
                  onTap: () {
                    showMoreBtn = false;
                    moreBtnLoading = false;
                    currSource = item;
                    setState(() {});
                    boop.selection();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: (Get.isDarkMode ? '#1c1c1e' : "#f0f0f0").$color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    child: Text(
                      item.name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ).copyWith(right: 18),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      spacing: 12,
                      children: videos.map((item) {
                        return GestureDetector(
                          onTap: () async {
                            var data = item;
                            if (item.videos.isEmpty) {
                              String id = item.id;
                              Get.dialog(
                                Center(
                                  child: Image.asset(
                                    "assets/loading.gif",
                                    width: 120,
                                    height: 120,
                                  ),
                                ),
                              );
                              var cx = home.mirrorList.firstWhere((item) {
                                return item.meta == currSource;
                              });
                              data = await cx.getDetail(id);
                              Get.back();
                            }
                            Get.toNamed(
                              Routes.PLAY,
                              arguments: data,
                            );
                          },
                          child: Zoom(
                            scaleRatio: .99,
                            child: Container(
                              decoration: BoxDecoration(
                                color: (Get.isDarkMode ? '#1c1c1e' : "#f0f0f0")
                                    .$color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              width: double.infinity,
                              height: 160,
                              padding: EdgeInsets.all(12),
                              child: Row(
                                spacing: 12,
                                children: [
                                  Builder(builder: (context) {
                                    String img = item.smallCoverImage;
                                    if (img.isEmpty) {
                                      return SizedBox.shrink();
                                    }
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(6.0),
                                      child: CachedNetworkImage(
                                        imageUrl: item.smallCoverImage,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: double.infinity,
                                        progressIndicatorBuilder:
                                            (context, url, progress) =>
                                                DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: .12),
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: progress.progress,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (_, __, ___) =>
                                            kErrorImage,
                                      ),
                                    );
                                  }),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          spacing: 6,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: TextStyle(
                                                color: Get.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (item.remark.isNotEmpty)
                                              Text(
                                                item.remark,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: (Get.isDarkMode
                                                          ? Colors.white
                                                          : Colors.black)
                                                      .withValues(alpha: .42),
                                                ),
                                              ),
                                            // Text(item.updateTime),
                                          ],
                                        ),
                                        Builder(builder: (context) {
                                          var source = item.getContext();
                                          if (source == null) {
                                            return const SizedBox.shrink();
                                          }
                                          var color = (Get.isDarkMode
                                                  ? '#a4a4a6'
                                                  : '#71727a')
                                              .$color;
                                          return Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: color,
                                                width: .72,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 3,
                                            ),
                                            child: Text(
                                              source.name,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: color,
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                width: context.mediaQuery.size.width - 120,
                left: 0,
                bottom: showMoreBtn ? 24 : -88,
                curve: Curves.easeIn,
                duration: Duration(milliseconds: 420),
                child: Center(
                  child: CupertinoButton.filled(
                    mouseCursor: SystemMouseCursors.click,
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 32),
                    sizeStyle: CupertinoButtonSize.medium,
                    child: Row(
                      spacing: 6,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (moreBtnLoading)
                          SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 1.8,
                            ),
                          ),
                        Text("加载更多", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    onPressed: () async {
                      moreBtnLoading = true;
                      if (mounted) setState(() {});
                      var cx = pagingMap[currSource];
                      if (cx == null || !cx.item2) return;
                      var axios = home.mirrorList.firstWhere((item) {
                        return item.meta == currSource;
                      });
                      var nextPage = cx.item1 + 1;
                      List<VideoDetail> list = [];
                      try {
                        list = await axios.getSearch(
                          keyword: keyword,
                          page: nextPage,
                        );
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                      moreBtnLoading = false;
                      showMoreBtn = false;
                      if (mounted) setState(() {});
                      map[currSource]!.addAll(list);
                      if (list.length == kDefaultPagingSize) {
                        pagingMap[currSource] = Tuple2(nextPage, true);
                      } else {
                        pagingMap[currSource] = Tuple2(nextPage, false);
                      }
                      if (mounted) setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (context.isDarkMode ? Colors.black : Colors.white)
          .withValues(alpha: .88),
      appBar: _buildAppBar(),
      floatingActionButton: _buildActionButton(),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Builder(builder: (context) {
          if (showHistory) {
            return _buildHistory();
          }
          if (searchDone && map.isEmpty) {
            return _buildEmpty();
          }
          if (isSearching && map.isEmpty) {
            return _buildLoading();
          }
          return _buildBody();
        }),
      ),
    );
  }
}
