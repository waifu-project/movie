import 'dart:async';
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/play/controllers/play_controller.dart';
import 'package:catmovie/app/modules/play/views/cast_screen.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:catmovie/isar/schema/video_search_schema.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:clipboard/clipboard.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/modules/home/views/parse_vip_manage.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:catmovie/widget/simple_html/flutter_html.dart';
import 'package:isar/isar.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:simple/x.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:tuple/tuple.dart';
import 'package:xi/xi.dart';
import 'package:media_kit/media_kit.dart';

enum PlaylistSort { down, up }

extension PlaylistSortExt on PlaylistSort {
  String get name {
    if (this == PlaylistSort.down) return "正序";
    return "倒序";
  }

  IconData get icon {
    if (this == PlaylistSort.down) return CupertinoIcons.sort_down;
    return CupertinoIcons.sort_up;
  }
}

class PlayState extends Equatable {
  const PlayState(this.tabIndex, this.index);
  final int tabIndex;
  final int index;

  @override
  List<Object?> get props => [tabIndex, index];
}

PlayState kEmptyPlayState = const PlayState(-1, -1);

class PlayView extends StatefulWidget {
  const PlayView({super.key});

  @override
  State<PlayView> createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> with AfterLayoutMixin {
  final PlayController play = Get.find<PlayController>();
  final HomeController home = Get.find<HomeController>();
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  late final Player player = Player();
  late final controller = VideoController(player);

  VideoKernel videoKernel = VideoKernel.webview;

  bool get canBeShowParseVipButton {
    return home.parseVipList.isNotEmpty;
  }

  double get screenHeight {
    var ret = MediaQuery.of(context).size.height;
    return ret;
  }

  List<PlayListData> playlist = [];

  Map<int, Widget> get tabviewData {
    Map<int, Widget> result = {};
    playlist.asMap().forEach((key, value) {
      result[key] = Text(value.title);
    });
    return result;
  }

  bool get canRenderIosStyle {
    return playlist.length >= 4;
  }

  final double offsetSize = 12;
  final coverHeightScale = .48;

  PlaylistSort playlistSort = PlaylistSort.down;

  bool get playlistIsEmpty {
    bool allEmpty = playlist.length == 1 && playlist[0].datas.isEmpty;
    return playlist.isEmpty || allEmpty;
  }

  int get playListGridCount {
    double screenWidth = context.mediaQuery.size.width;
    double minCardWidth = 188;
    double spacing = 5;
    int count = ((screenWidth + spacing) / (minCardWidth + spacing)).floor();
    count = count.clamp(1, 6);
    return count;
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    focusNode.requestFocus();
    videoKernel = getSettingAsKeyIdent<VideoKernel>(SettingsAllKey.videoKernel);
    playlist = videoInfo2PlayListData(play.movieItem.videos);
    loadHistory();
    if (mounted) setState(() {});
  }

  void loadHistory() {
    var item = play.movieItem;
    var cx = item.getContext()!;
    play.historyContext = videoHistoryAs
        .filter()
        .isNsfwEqualTo(home.isNsfw)
        .sidEqualTo(cx.id)
        .ctx((cx) {
      return cx.detailIDEqualTo(item.id);
    }).findFirstSync();
    if (play.historyContext == null) return;
    var tabIndex = play.historyContext!.ctx.pTabIndex;
    var index = play.historyContext!.ctx.pIndex;
    debugPrint("load history t: $tabIndex, i: $index");
    if (tabIndex <= -1 || index <= -1) return;
    if (videoKernel.isMediaKit) {
      handlePlay(tabIndex, index);
    }
  }

  @override
  void dispose() {
    player.dispose().catchError((error) {
      debugPrint("player dispose error: $error");
    });
    super.dispose();
  }

  Future<void> handlePlay(int tabIndex, int index) async {
    var realPlaylist = playlist[tabIndex].datas;
    var curr = playlist[tabIndex].datas[index];
    var isUpSort = playlistSort == PlaylistSort.up;
    var isOk = await play.handleTapPlayerButtom(
      curr,
      realPlaylist,
      tabIndex,
      videoKernel,
      player,
      isUpSort,
    );
    if (!isOk) return;
    var realIndex = index;
    if (isUpSort) {
      realIndex = getReversalIndex(realPlaylist, index);
    }
    Future.delayed(const Duration(milliseconds: 124), () {
      play.updatePlayState(tabIndex, index, realIndex, curr.name);
    });
  }

  void handleSortPlaylist() {
    if (playlistSort == PlaylistSort.down) {
      playlistSort = PlaylistSort.up;
    } else {
      playlistSort = PlaylistSort.down;
    }
    playlist.asMap().forEach((idx, item) {
      playlist[idx].datas = item.datas.reversed.toList();
    });
    var idx = getReversalIndex(playlist[0].datas, play.playState.index);
    // play.playState = kEmptyPlayState;
    play.playState = PlayState(play.playState.tabIndex, idx);
    play.update();
    EasyLoading.showToast(
      "切换到${playlistSort.name}",
      toastPosition: EasyLoadingToastPosition.bottom,
    );
    setState(() {});
  }

  Widget _buildCoverImage() {
    return Positioned.fill(
      child: CachedNetworkImage(
        imageUrl: play.movieItem.smallCoverImage,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildMediaKit() {
    return Positioned.fill(
      child: Video(
        fill: Colors.transparent,
        // TODO(d1y): support dynamic set box-fit
        fit: BoxFit.cover,
        controller: controller,
        onEnterFullscreen: () async {
          await defaultEnterNativeFullscreen();
          // workaround: 在 iOS 上全屏之后播放会暂停
          if (GetPlatform.isIOS) {
            Future.delayed(const Duration(milliseconds: 88), () {
              controller.player.pause();
              controller.player.play();
            });
          }
        },
        onExitFullscreen: () async {
          await defaultExitNativeFullscreen();
          if (GetPlatform.isMobile) {
            SystemChrome.setPreferredOrientations(
              [
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCover() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(child: SizedBox.shrink()),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Colors.black12,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 24,
              sigmaY: 24,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 24,
              ),
              child: Text(
                play.movieItem.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: context.isDarkMode ? Colors.white : Colors.black),
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var cardHeight = context.mediaQuery.size.width * (6 / 12);
    var hh = context.mediaQuery.size.height * .51;
    if (cardHeight >= hh) cardHeight = hh;
    if (cardHeight <= 200) cardHeight = 240;
    return GetBuilder<PlayController>(
      builder: (play) => Scaffold(
        appBar: CupertinoEasyAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        child: videoKernel.isMediaKit
                            ? Container(
                                padding: EdgeInsets.symmetric(vertical: 12)
                                    .copyWith(right: 24),
                                child: Row(
                                  spacing: 6,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(CupertinoIcons.back, size: 28),
                                    Expanded(
                                      child: Text(
                                        play.movieItem.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                color: context.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Row(
                                children: [
                                  Zoom(
                                    child: CupertinoNavigationBarBackButton(
                                        onPressed: () {}),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 120,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          var ps = play.playState;
                          if (ps == kEmptyPlayState) {
                            Get.back();
                            return;
                          }
                          var curr = playlist[ps.tabIndex].datas[ps.index];
                          Get.back(result: Tuple2(play.playState, curr.name));
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: SizedBox.expand(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (canBeShowParseVipButton)
                Zoom(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                    ),
                    child: const Row(
                      children: [
                        Icon(CupertinoIcons.collections, size: 16),
                        SizedBox(width: 6.0),
                        Text(
                          "解析源",
                          style: TextStyle(fontSize: 14.0),
                        ),
                        SizedBox(width: 2.0),
                      ],
                    ),
                    onPressed: () {
                      Get.to(() => const ParseVipManagePageView());
                    },
                  ),
                ),
            ],
          ),
        ),
        body: Shortcuts(
          shortcuts: {
            // esc
            const SingleActivator(LogicalKeyboardKey.escape):
                const DismissIntent(),
            // backspace
            const SingleActivator(LogicalKeyboardKey.backspace):
                const DismissIntent(),
            // enter
            const SingleActivator(LogicalKeyboardKey.enter):
                const ActivateIntent(),
            // ctrl-p
            const SingleActivator(LogicalKeyboardKey.keyP, control: true):
                ScrollUpIntent(),
            // ctrl-n
            const SingleActivator(LogicalKeyboardKey.keyN, control: true):
                ScrollDownIntent(),
            // // cmd-shift-[
            // const SingleActivator(LogicalKeyboardKey.braceLeft /* { */,
            //     meta: true, shift: true): TabSwitchLeftIntent(),
            // // cmd-shift-]
            // const SingleActivator(LogicalKeyboardKey.braceRight /* } */,
            //     meta: true, shift: true): TabSwitchRightIntent(),
          },
          child: Actions(
            actions: {
              DismissIntent: CallbackAction<DismissIntent>(
                onInvoke: (_) {
                  Get.back();
                  return null;
                },
              ),
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  // 如果只有一集的话, 敲击 `enter` 键自动播放
                  var cx = playlist[play.tabIndex].datas;
                  if (cx.length == 1) {
                    handlePlay(play.tabIndex, 0);
                  }
                  return null;
                },
              ),
              ScrollUpIntent: CallbackAction<ScrollUpIntent>(
                onInvoke: (_) {
                  scrollUp(scrollController);
                  return null;
                },
              ),
              ScrollDownIntent: CallbackAction<ScrollDownIntent>(
                onInvoke: (_) {
                  scrollDown(scrollController);
                  return null;
                },
              ),
            },
            child: Focus(
              autofocus: true,
              focusNode: focusNode,
              child: SafeArea(
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.white : Colors.black,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: cardHeight,
                        child: Stack(
                          children: [
                            _buildCoverImage(),
                            if (videoKernel.isMediaKit)
                              Positioned.fill(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRect(
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: CachedNetworkImage(
                                                imageUrl: play
                                                    .movieItem.smallCoverImage,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned.fill(
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 24, sigmaY: 24),
                                                child: Container(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: .12)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            play.movieItem.smallCoverImage,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            if (videoKernel.isMediaKit)
                              _buildMediaKit()
                            else
                              _buildCover()
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWithDesc,
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "播放列表",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  if (!playlistIsEmpty &&
                                      playlist[play.tabIndex].datas.length >= 2)
                                    IconButton(
                                      tooltip: playlistSort.name,
                                      onPressed: handleSortPlaylist,
                                      icon: Icon(playlistSort.icon),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: canRenderIosStyle ? 32 + 12 : null,
                              decoration: canRenderIosStyle
                                  ? BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color:
                                              Colors.grey.withValues(alpha: .2),
                                          width: 1,
                                        ),
                                      ),
                                    )
                                  : null,
                              padding: canRenderIosStyle
                                  ? const EdgeInsets.only(
                                      bottom: 12,
                                    )
                                  : null,
                              child: Builder(builder: (_) {
                                var isNext = playlist.length <= 1 ||
                                    tabviewData[1] == null;
                                if (isNext) return const SizedBox.shrink();
                                if (canRenderIosStyle) {
                                  return SmoothListView.builder(
                                    duration: kSmoothListViewDuration,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: playlist.length,
                                    itemBuilder: (context, index) {
                                      var isCurrentIndex =
                                          index == play.tabIndex;
                                      var current = playlist[index];
                                      var currentBorderColor = isCurrentIndex
                                          ? CupertinoTheme.of(context)
                                              .primaryColor
                                          : (context.isDarkMode
                                                  ? Colors.white
                                                  : Colors.black)
                                              .withValues(alpha: .42);
                                      return GestureDetector(
                                        onTap: () {
                                          play.changeTabIndex(index);
                                        },
                                        child: AnimatedContainer(
                                          alignment: Alignment.center,
                                          height: 32,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: currentBorderColor,
                                            ),
                                          ),
                                          margin: const EdgeInsets.only(
                                            right: 6,
                                            left: 9,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                          child: Text(
                                            current.title,
                                            style: TextStyle(
                                              color: currentBorderColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12)
                                      .copyWith(bottom: 12),
                                  child: CupertinoSlidingSegmentedControl(
                                    backgroundColor: Colors.black26,
                                    thumbColor: context.isDarkMode
                                        ? Colors.blue
                                        : Colors.white,
                                    onValueChanged: (value) {
                                      if (value == null) return;
                                      play.changeTabIndex(value);
                                    },
                                    groupValue: play.tabIndex,
                                    children: tabviewData,
                                  ),
                                );
                              }),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: offsetSize),
                                child: Builder(builder: (context) {
                                  if (playlistIsEmpty) {
                                    return emptyPlaylistWidget;
                                  }
                                  return GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: playListGridCount,
                                      mainAxisExtent: 48,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                    itemCount:
                                        playlist[play.tabIndex].datas.length,
                                    itemBuilder: (context, index) {
                                      var curr =
                                          playlist[play.tabIndex].datas[index];
                                      String playUrl = curr.url;
                                      var isCast = playUrl.endsWith(".m3u8") ||
                                          playUrl.endsWith(".mp4");
                                      return Builder(builder: (menuContext) {
                                        return PullDownButton(
                                          itemBuilder: (context) {
                                            return [
                                              PullDownMenuItem(
                                                onTap: () async {
                                                  await FlutterClipboard.copy(
                                                    playUrl,
                                                  );
                                                  EasyLoading.showToast(
                                                    "复制链接成功",
                                                    maskType:
                                                        EasyLoadingMaskType
                                                            .none,
                                                  );
                                                },
                                                title: '复制链接',
                                                icon: CupertinoIcons
                                                    .doc_on_clipboard,
                                              ),
                                              if (isCast)
                                                PullDownMenuItem(
                                                  title: '投屏播放',
                                                  subtitle: '仅支持局域网里的设备',
                                                  onTap: () {
                                                    showCupertinoModalBottomSheet(
                                                        context: context,
                                                        backgroundColor:
                                                            (context.isDarkMode
                                                                    ? Colors
                                                                        .black
                                                                    : Colors
                                                                        .white)
                                                                .withValues(
                                                                    alpha: .88),
                                                        builder: (
                                                          BuildContext context,
                                                        ) {
                                                          return CastScreen(
                                                            onTapDevice:
                                                                (cx) async {
                                                              try {
                                                                await cx.setUrl(
                                                                    playUrl);
                                                                await cx.play();
                                                                // TODO: 支持控制远程DLNA设备
                                                                if (!context
                                                                    .mounted) {
                                                                  return;
                                                                }
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                EasyLoading
                                                                    .showToast(
                                                                  "即将开始投屏播放",
                                                                  toastPosition:
                                                                      EasyLoadingToastPosition
                                                                          .bottom,
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          240),
                                                                );
                                                              } catch (e) {
                                                                EasyLoading
                                                                    .showToast(
                                                                  "播放失败",
                                                                  toastPosition:
                                                                      EasyLoadingToastPosition
                                                                          .bottom,
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          240),
                                                                );
                                                              }
                                                            },
                                                          );
                                                        });
                                                  },
                                                  icon: CupertinoIcons.tv,
                                                ),
                                              // PullDownMenuItem(
                                              //   onTap: () {},
                                              //   title: '删除',
                                              //   isDestructive: true,
                                              //   icon: CupertinoIcons.delete,
                                              // ),
                                            ];
                                          },
                                          buttonBuilder: (context, showMenu) {
                                            return HoverCursor(
                                              child: CupertinoButton.filled(
                                                color: (context.isDarkMode
                                                        ? '#222222'
                                                        : '#f4e8f8')
                                                    .$color,
                                                padding: EdgeInsets.zero,
                                                child: Builder(builder: (cx) {
                                                  var text = curr.name;
                                                  var ps = play.playState;
                                                  var lastedPlay =
                                                      ps.tabIndex ==
                                                              play.tabIndex &&
                                                          index == ps.index;
                                                  var textColor =
                                                      context.isDarkMode
                                                          ? Colors.white
                                                          : Colors.black;
                                                  if (lastedPlay) {
                                                    text += "(上次播放)";
                                                    textColor =
                                                        Color(0xFF6750A4);
                                                  }
                                                  return Text(
                                                    text,
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                }),
                                                onPressed: () {
                                                  handlePlay(
                                                    play.tabIndex,
                                                    index,
                                                  );
                                                },
                                                onLongPress: () {
                                                  showMenu();
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      });
                                    },
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  final Style _textOncelineStyle = Style(
    textOverflow: TextOverflow.ellipsis,
    maxLines: 1,
    fontSize: const FontSize(
      12,
    ),
    height: 24,
  );

  final List<String> _textIncludeTags = [
    "p",
    "span",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "pre",
  ];

  Map<String, Style> get _shortDescStyleWithHTML {
    Map<String, Style> map = {};
    for (var ele in _textIncludeTags) {
      map[ele] = _textOncelineStyle;
    }
    return map;
  }

  Widget _buildWithShortDesc(String desc) {
    String humanDesc = desc.trim();
    if (humanDesc.isEmpty) return const SizedBox.shrink();
    // NOTE: 不是标签,实际上不是很严谨!!
    if (humanDesc[0] != '<') {
      return Text(
        humanDesc,
        maxLines: 1,
        style: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: 12,
          color: context.isDarkMode ? Colors.white : Colors.black,
        ),
      );
    }
    return Html(
      data: humanDesc,
      style: _shortDescStyleWithHTML,
    );
  }

  Widget get _buildWithDesc {
    var desc = play.movieItem.desc;
    if (desc.isEmpty || desc == "暂无简介") {
      return SizedBox.shrink();
      // return Container(
      //   margin: const EdgeInsets.symmetric(
      //     horizontal: 12,
      //     vertical: 9,
      //   ),
      //   child: const Text('暂无简介~'),
      // );
    }
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: false,
        subtitle: _buildWithShortDesc(desc),
        title: Text(
          '查看简介',
          style: TextStyle(
            fontSize: 18,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * .33,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Html(
                  data: desc,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get emptyPlaylistWidget {
    return Center(
      child: Column(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.tornado,
            size: 42,
            color: CupertinoColors.systemBlue,
          ),
          Text(
            "暂无播放链接",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
