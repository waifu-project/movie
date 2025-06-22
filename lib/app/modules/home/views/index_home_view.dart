import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/routes/app_pages.dart';
import 'package:movie/app/widget/k_body.dart';
import 'package:movie/app/widget/k_empty_mirror.dart';
import 'package:movie/app/widget/k_error_stack.dart';
import 'package:movie/app/widget/movie_card_item.dart';
import 'package:movie/app/widget/window_appbar.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:simple/x.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:xi/xi.dart';

const scrollSize = 240;

shortcutCallback<T extends Intent>(int curr, VoidCallback cb) {
  return CallbackAction(onInvoke: (_) {
    if (curr != 0) return;
    cb();
    return null;
  });
}

class IndexHomeView extends StatefulWidget {
  const IndexHomeView({super.key});

  @override
  createState() => _IndexHomeViewState();
}

class _IndexHomeViewState extends State<IndexHomeView>
    with AutomaticKeepAliveClientMixin {
  HomeController controller = Get.find<HomeController>();

  ScrollController scrollController = ScrollController();

  int get cardCount {
    bool isLandscape = context.isLandscape;
    if (GetPlatform.isMobile && !isLandscape) return 3;
    var w = controller.windowLastSize.width;
    if (w >= 1248) return 5;
    return 3;
  }

  /// 错误日志
  String get errorMsg => controller.indexHomeLoadDataErrorMessage;

  /// 错误日志最大展示行数
  int get errorMsgMaxLines => 12;

  handleClickItem(VideoDetail subItem, HomeController cx) async {
    var data = subItem;
    if (subItem.videos.isEmpty) {
      var id = subItem.id;
      var textStyle =
          Theme.of(Get.context as BuildContext).textTheme.bodyMedium!.copyWith(
                color: CupertinoColors.systemBlue,
              );
      Get.dialog(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                "加载中",
                style: textStyle,
              ),
            ],
          ),
        ),
        barrierColor: CupertinoColors.inactiveGray.withValues(alpha: .9),
      );
      data = await controller.currentMirrorItem.getDetail(id);
      Get.back();
    }
    Get.toNamed(
      Routes.PLAY,
      arguments: data,
    );
  }

  /// 每个卡片的高度
  /// 用设备高度 * 0.33
  /// 横屏情况下 * 0.42
  double get _cardOnceHeight {
    double scan = .27;
    if (cardCount >= 5) scan = .42;
    return Get.height * scan;
  }

  double get _calcImageWidth {
    var width = controller.windowLastSize.width;
    // 桌面平台
    if (width >= 500) return 120;
    return width * .6;
  }

  bool get indexEnablePullDown {
    return !controller.isLoading;
  }

  bool get indexEnablePullUp {
    return !controller.isLoading && controller.homedata.isNotEmpty;
  }

  String get currentTitle {
    try {
      return controller.currentMirrorItem.meta.name;
    } catch (e) {
      return "yoyo";
    }
  }

  bool get categoryIsEmpty {
    return controller.currentCategoryer.isEmpty;
  }

  int get currCategoryIndex {
    var now = controller.currentCategoryerNow;
    if (now == null) return -1;
    return controller.currentCategoryer.indexOf(now);
  }

  switchCategory(SourceSpiderQueryCategory curr) {
    if (curr == controller.currentCategoryerNow) {
      return;
    }
    controller.setCurrentCategoryerNow(curr);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<HomeController>(
      builder: (homeview) => Scaffold(
        appBar: WindowAppBar(
          iosBackStyle: true,
          title: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
            ),
            child: Text(
              currentTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          actions: [
            if (!controller.mirrorListIsEmpty)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: CupertinoButton(
                  child: const Icon(
                    Icons.movie,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    homeview.showMirrorModel(context);
                  },
                ),
              ),
          ],
        ),
        body: Shortcuts(
          shortcuts: {
            // ctrl-p
            const SingleActivator(LogicalKeyboardKey.keyP, control: true):
                ScrollUpIntent(),
            // ctrl-n
            const SingleActivator(LogicalKeyboardKey.keyN, control: true):
                ScrollDownIntent(),
            // ctrl-k
            const SingleActivator(LogicalKeyboardKey.keyK, control: true):
                ScrollUpIntent(),
            // ctrl-j
            const SingleActivator(LogicalKeyboardKey.keyJ, control: true):
                ScrollDownIntent(),
            // cmd-[
            const SingleActivator(LogicalKeyboardKey.bracketLeft, meta: true):
                CategoryPrevIntent(),
            // cmd-]
            const SingleActivator(LogicalKeyboardKey.bracketRight, meta: true):
                CategoryNextIntent(),
          },
          child: Actions(
            actions: {
              ScrollUpIntent: shortcutCallback(controller.currentBarIndex, () {
                scrollUp(scrollController);
              }),
              ScrollDownIntent:
                  shortcutCallback(controller.currentBarIndex, () {
                scrollDown(scrollController);
              }),
              CategoryPrevIntent:
                  shortcutCallback(controller.currentBarIndex, () {
                if (categoryIsEmpty || currCategoryIndex == 0) return;
                var cx = controller.currentCategoryer[currCategoryIndex - 1];
                switchCategory(cx);
              }),
              CategoryNextIntent:
                  shortcutCallback(controller.currentBarIndex, () {
                if (categoryIsEmpty ||
                    currCategoryIndex ==
                        controller.currentCategoryer.length - 1) return;
                var cx = controller.currentCategoryer[currCategoryIndex + 1];
                switchCategory(cx);
              }),
            },
            child: KeyboardListener(
              focusNode: controller.homeFocusNode,
              autofocus: true,
              child: KBody(
                child: Column(
                  children: [
                    AnimatedContainer(
                      width: double.infinity,
                      height: !categoryIsEmpty ? 42 : 0,
                      duration: const Duration(
                        milliseconds: 420,
                      ),
                      curve: Curves.decelerate,
                      child: ListView.builder(
                        itemCount: controller.currentCategoryer.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: ((context, index) {
                          SourceSpiderQueryCategory curr =
                              controller.currentCategoryer[index];
                          bool isCurr = curr == controller.currentCategoryerNow;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.2,
                              vertical: 6.2,
                            ),
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              color: isCurr ? CupertinoColors.systemBlue : null,
                              child: Text(
                                curr.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isCurr
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .color,
                                ),
                              ),
                              onPressed: () {
                                switchCategory(curr);
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    Expanded(
                      child: Builder(builder: (context) {
                        if (controller.mirrorListIsEmpty) {
                          return KEmptyMirror(
                            cx: controller,
                            width: _calcImageWidth,
                            context: context,
                          );
                        }
                        return SmartRefresher(
                          enablePullDown: indexEnablePullDown,
                          enablePullUp: indexEnablePullUp,
                          header: const WaterDropHeader(
                            refresh: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CupertinoActivityIndicator(),
                                SizedBox(
                                  width: 12,
                                ),
                                Text("加载中"),
                              ],
                            ),
                            complete: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.smiley),
                                SizedBox(
                                  width: 12,
                                ),
                                Text("加载完成"),
                              ],
                            ),
                          ),
                          footer: CustomFooter(
                            builder: (BuildContext context, LoadStatus? mode) {
                              Widget body;
                              if (mode == LoadStatus.idle) {
                                body = const Text("上划加载更多");
                              } else if (mode == LoadStatus.loading) {
                                body = const CupertinoActivityIndicator();
                              } else if (mode == LoadStatus.failed) {
                                body = const Text("加载失败, 请重试");
                              } else if (mode == LoadStatus.canLoading) {
                                body = const Text("释放以加载更多");
                              } else {
                                body = const Text("没有更多数据");
                              }
                              return Center(
                                child: body,
                              );
                            },
                          ),
                          scrollController: scrollController,
                          controller: homeview.refreshController,
                          onLoading: homeview.refreshOnLoading,
                          onRefresh: homeview.refreshOnRefresh,
                          child: Builder(
                            builder: (_) {
                              if (homeview.isLoading) {
                                return const SizedBox.shrink();
                              }
                              if (homeview.homedata.isEmpty) {
                                if (errorMsg.isNotEmpty) {
                                  return Center(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            "assets/images/error.png",
                                            width: Get.width * .24,
                                          ),
                                          const SizedBox(
                                            height: 24,
                                          ),
                                          CupertinoButton.filled(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12.0,
                                              horizontal: 24.0,
                                            ),
                                            onPressed: () {
                                              homeview.updateHomeData(
                                                  isFirst: true);
                                            },
                                            child: const Text(
                                              "重新加载",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          KErrorStack(
                                            msg: errorMsg,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return Center(
                                    child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      "assets/images/error.png",
                                      width: Get.width * .24,
                                    ),
                                    const SizedBox(height: 24),
                                    const Text("当前请求列表为空"),
                                  ],
                                ));
                              }
                              return WaterfallFlow.builder(
                                controller: ScrollController(),
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cardCount,
                                  crossAxisSpacing: 5.0,
                                  mainAxisSpacing: 5.0,
                                ),
                                itemCount: homeview.homedata.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var subItem = homeview.homedata[index];
                                  var scale = index % 2 == 0 ? 1 : .8;
                                  var h = _cardOnceHeight * scale;
                                  return SizedBox(
                                    height: h,
                                    child: MovieCardItem(
                                      imageUrl: subItem.smallCoverImage,
                                      title: subItem.title,
                                      onTap: () {
                                        handleClickItem(subItem, controller);
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
