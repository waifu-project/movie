import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/home/views/history.dart';
import 'package:catmovie/app/modules/home/views/onboarding.dart';
import 'package:catmovie/app/modules/home/views/search.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:catmovie/utils/boop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/routes/app_pages.dart';
import 'package:catmovie/app/widget/k_body.dart';
import 'package:catmovie/app/widget/k_empty_mirror.dart';
import 'package:catmovie/app/widget/k_error_stack.dart';
import 'package:catmovie/app/widget/movie_card_item.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:simple/x.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:xi/xi.dart';

double kHomeMovieCardSpacing = 9;

CallbackAction<Intent> shortcutCallback<T extends Intent>(
    int curr, VoidCallback cb) {
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
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin {
  HomeController controller = Get.find<HomeController>();

  ScrollController scrollController = ScrollController();

  int get cardCount {
    double screenWidth = context.mediaQuery.size.width;
    double minCardWidth = 188;
    double spacing = kHomeMovieCardSpacing;
    int count = ((screenWidth + spacing) / (minCardWidth + spacing)).floor();
    count = count.clamp(1, 6);
    return count;
  }

  /// 错误日志
  String get errorMsg => controller.indexHomeLoadDataErrorMessage;

  /// 错误日志最大展示行数
  int get errorMsgMaxLines => 12;

  Future<void> handleClickItem(VideoDetail subItem, HomeController cx) async {
    var data = subItem;
    if (subItem.videos.isEmpty) {
      var id = subItem.id;
      var isNext = await showLoadingPlaceholderTask(() async {
        data = await controller.currentMirrorItem.getDetail(id);
      });
      if (!isNext) return;
    }
    data.setContext(controller.currentMirrorItem.meta);
    Get.toNamed(
      Routes.PLAY,
      arguments: data,
    );
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
      return "小猫影视";
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

  void switchCategory(SourceSpiderQueryCategory curr) {
    if (curr == controller.currentCategoryerNow) {
      return;
    }
    controller.setCurrentCategoryerNow(curr);
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    initWithOnBoarding();
  }

  void initWithOnBoarding() {
    if (getSettingAsKeyIdent<bool>(SettingsAllKey.onBoardingShowed)) return;
    showCupertinoModalBottomSheet(
      context: context,
      topRadius: Radius.circular(24),
      builder: (_) => OnBoarding(
        onNext: () {
          updateSetting(SettingsAllKey.onBoardingShowed, true);
          controller.updateHomeData(isFirst: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<HomeController>(
      builder: (homeview) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: WindowAppBar(
          iosBackStyle: true,
          title: Zoom(
            onTap: () {
              EasyLoading.dismiss();
              homeview.showMirrorModel(context);
              boop.selection();
            },
            child: Builder(builder: (context) {
              // var logo = homeview.currentMirrorItem.meta.logo;
              // if (logo.isNotEmpty) {
              //   return CachedNetworkImage(imageUrl: logo, width: 120,);
              // }
              return Row(
                spacing: 6,
                children: [
                  // Icon(
                  //   CupertinoIcons.arrowtriangle_right_square_fill,
                  //   color: context.isDarkMode ? Colors.white : Colors.black,
                  //   size: 28,
                  // ),
                  // https://www.iconfont.cn/user/detail?spm=a313x.search_index.0.d214f71f6.7fd43a81jlqJoE&uid=149438&nid=WJvLCUeSEEyE
                  SvgPicture.string(
                    r"""
<svg t="1757795810585" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="8443" width="200" height="200"><path d="M909.31 307.42c-32.09-36.66-77.05-62.04-128.53-68.91-6.36-0.85-12.73-1.67-19.1-2.45l68.58-98.85c12.86-18.58 8.27-44.07-10.31-56.93-18.6-12.94-44.07-8.27-56.93 10.27L668.57 226.7h-0.01c-52.57-4.07-105.26-6.11-157.95-6.11s-105.37 2.04-157.94 6.11h-0.01L258.21 90.54c-12.9-18.54-38.43-23.21-56.93-10.27-18.58 12.86-23.17 38.35-10.31 56.93l68.59 98.85c-6.37 0.78-12.74 1.6-19.1 2.45C137.51 252.24 60.62 340.06 60.62 443.92v288.06c0 51.93 19.22 99.85 51.31 136.5 32.09 36.66 77.05 62.04 128.53 68.91a2043.998 2043.998 0 0 0 540.32 0c102.95-13.73 179.84-101.55 179.84-205.41V443.92c0-51.93-19.22-99.85-51.31-136.5z m-267.5 315.96l-148.1 115.6c-29.51 23.04-72.61 2.01-72.61-35.43v-231.2c0-37.44 43.1-58.47 72.61-35.43l148.1 115.59c23.06 18 23.06 52.88 0 70.87z" p-id="8444"></path></svg>
""",
                    width: 30,
                    colorFilter: ColorFilter.mode(
                      context.isDarkMode ? Colors.white : Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  Text(
                    currentTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              );
            }),
          ),
          actions: [
            Zoom(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.search,
                  size: 24,
                  color: context.isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  EasyLoading.dismiss();
                  if (homeview.mirrorListIsEmpty) {
                    EasyLoading.showError('暂无可用源');
                    return;
                  }
                  Get.to(() => const SearchV2());
                },
              ),
            ),
            Zoom(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.clock,
                  size: 24,
                  color: context.isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  EasyLoading.dismiss();
                  Get.to(() => const HistoryPage());
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
            // cmd-t
            const SingleActivator(LogicalKeyboardKey.keyT, meta: true):
                MirrorTableIntent(),
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
                        controller.currentCategoryer.length - 1) {
                  return;
                }
                var cx = controller.currentCategoryer[currCategoryIndex + 1];
                switchCategory(cx);
              }),
              MirrorTableIntent:
                  shortcutCallback(controller.currentBarIndex, () {
                homeview.showMirrorModel(context);
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
                      child: SmoothListView.builder(
                        duration: kSmoothListViewDuration,
                        itemCount: controller.currentCategoryer.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: ((context, index) {
                          SourceSpiderQueryCategory curr =
                              controller.currentCategoryer[index];
                          bool isCurr = curr == controller.currentCategoryerNow;
                          return Zoom(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.2,
                                vertical: 6.2,
                              ),
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                color: isCurr
                                    ? (context.isDarkMode
                                            ? "#f1f1f1"
                                            : "#0f0f0f")
                                        .$color
                                    : (context.isDarkMode
                                            ? '#272727'
                                            : "#e2e8f0")
                                        .$color,
                                child: Text(
                                  curr.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isCurr
                                        ? (context.isDarkMode
                                            ? Colors.black
                                            : Colors.white)
                                        : Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .color,
                                  ),
                                ),
                                onPressed: () {
                                  EasyLoading.dismiss();
                                  switchCategory(curr);
                                  boop.selection();
                                },
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 6),
                    Expanded(
                      child: Builder(builder: (context) {
                        if (controller.mirrorListIsEmpty) {
                          return KEmptyMirror(
                            cx: controller,
                            width: _calcImageWidth,
                            context: context,
                          );
                        }
                        return RefreshConfiguration(
                          springDescription: const SpringDescription(
                            mass: 1,
                            stiffness: 364.71867768595047,
                            damping: 35.2,
                          ),
                          child: SmartRefresher(
                            header: const WaterDropHeader(
                              refresh: Row(
                                spacing: 12,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CupertinoActivityIndicator(),
                                  Text("加载中"),
                                ],
                              ),
                              complete: Row(
                                spacing: 12,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.smiley),
                                  Text("加载完成"),
                                ],
                              ),
                            ),
                            footer: CustomFooter(
                              builder:
                                  (BuildContext context, LoadStatus? mode) {
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
                                return Center(child: body);
                              },
                            ),
                            enablePullDown: indexEnablePullDown,
                            enablePullUp: indexEnablePullUp,
                            scrollController: scrollController,
                            physics: const BouncingScrollPhysics(),
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
                                    return SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: Column(
                                        children: [
                                          SizedBox(height: 42),
                                          Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              spacing: 12,
                                              children: [
                                                Image.asset(
                                                  "assets/images/error.png",
                                                  width: 120,
                                                  height: 120,
                                                ),
                                                Zoom(
                                                  child: CupertinoButton.filled(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 12.0,
                                                      horizontal: 24.0,
                                                    ),
                                                    onPressed: () {
                                                      boop.selection();
                                                      homeview.updateHomeData(
                                                          isFirst: true);
                                                    },
                                                    child: const Text(
                                                      "重新加载",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            height:
                                                context.mediaQuery.size.height *
                                                    .42,
                                            child: KErrorStack(msg: errorMsg),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return Column(
                                    spacing: 12,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: 42),
                                      Image.asset(
                                        "assets/images/error.png",
                                        width: 120,
                                        height: 120,
                                      ),
                                      Text("当前请求列表为空",
                                          style: TextStyle(
                                            color: (context.isDarkMode
                                                    ? '#6f737a'
                                                    : '#767a82')
                                                .$color,
                                          )),
                                      SizedBox(height: 88),
                                    ],
                                  );
                                }
                                return GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: cardCount,
                                    crossAxisSpacing: kHomeMovieCardSpacing,
                                    mainAxisSpacing: kHomeMovieCardSpacing,
                                    childAspectRatio: 12 / 9,
                                  ),
                                  itemCount: homeview.homedata.length,
                                  itemBuilder: (
                                    BuildContext context,
                                    int index,
                                  ) {
                                    var subItem = homeview.homedata[index];
                                    return MovieCardItem(
                                      imageUrl: subItem.smallCoverImage,
                                      title: subItem.title,
                                      note: subItem.remark,
                                      onTap: () {
                                        EasyLoading.dismiss();
                                        handleClickItem(subItem, controller);
                                        boop.selection();
                                      },
                                    );
                                  },
                                );
                              },
                            ),
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
