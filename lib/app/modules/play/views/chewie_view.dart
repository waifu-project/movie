import 'dart:async';
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:hide_cursor/hide_cursor.dart';
import 'package:media_kit/media_kit.dart';
import 'package:video_player/video_player.dart';
import 'package:xi/xi.dart';

import 'custom_play.dart';

class ChewieView extends StatefulWidget {
  const ChewieView({super.key});

  @override
  createState() => _ChewieViewState();
}

class _ChewieViewState extends State<ChewieView> with AfterLayoutMixin {
  ChewieController? chewieController;
  VideoPlayerController? videoPlayerController;
  bool showTopbar = true;
  bool isLoading = false;

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    if (GetPlatform.isDesktop) {
      hideCursor.showCursor();
    }
    if (initHook()) {
      init(currVideo!);
    }
  }

  @override
  void dispose() {
    if (GetPlatform.isDesktop) {
      hideCursor.showCursor();
    }

    // 先设置标志，防止异步操作继续执行
    isLoading = true;

    try {
      chewieController?.dispose();
    } catch (e) {
      print('Error disposing chewieController: $e');
    }

    try {
      videoPlayerController?.dispose();
    } catch (e) {
      print('Error disposing videoPlayerController: $e');
    }

    chewieController = null;
    videoPlayerController = null;

    super.dispose();
  }

  String cover = "";
  List<VideoInfo> videos = [];
  VideoInfo? currVideo;

  String get playUrl {
    if (currVideo == null) {
      return "";
    }
    return currVideo!.url;
  }

  bool initHook() {
    var args = Get.arguments ?? {};
    var _curr = args['curr'];
    if (_curr is! VideoInfo) {
      return false;
    }
    var _list = args['playlist'];
    if (_list is! List<VideoInfo>) {
      return false;
    }
    videos = _list;
    currVideo = _curr;
    cover = args["cover"] ?? "";
    setState(() {});
    return true;
  }

  Future<void> init(VideoInfo cx) async {
    if (!mounted) return;

    print('开始加载视频: ${cx.url}');

    try {
      // 立即显示 loading
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      // 完全清理旧的 controllers
      if (chewieController != null) {
        try {
          chewieController!.dispose();
        } catch (e) {
          print('清理 ChewieController 错误: $e');
        }
        chewieController = null;
      }

      if (videoPlayerController != null) {
        try {
          await videoPlayerController!.dispose();
        } catch (e) {
          print('清理 VideoPlayerController 错误: $e');
        }
        videoPlayerController = null;
      }

      // 等待确保清理完成
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      // 创建新的 VideoPlayerController
      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(cx.url));
      await videoPlayerController!.initialize();

      if (!mounted || videoPlayerController == null) return;

      // 创建新的 ChewieController
      chewieController = ChewieController(
        optionsTranslation: OptionsTranslation(
          playbackSpeedButtonText: '播放速度',
          cancelButtonText: "取消",
          subtitlesButtonText: "字幕",
        ),
        videoPlayerController: videoPlayerController!,
        autoInitialize: true,
        autoPlay: true,
        fullScreenByDefault: !GetPlatform.isDesktop,
        showControls: true,
        showControlsOnInitialize: true,
        allowMuting: false,
        allowFullScreen: !GetPlatform.isDesktop,
        allowedScreenSleep: false,
        useRootNavigator: false,
        customControls: CustomCupertinoControls(
          backgroundColor: Colors.black38,
          iconColor: Colors.white,
          onTapEpisodes: () {
            openPlayList();
          },
          onControlsVisibilityChanged: (isVisible) {
            if (mounted) {
              showTopbar = isVisible;
              setState(() {});
              if (GetPlatform.isDesktop) {
                if (isVisible) {
                  hideCursor.showCursor();
                } else {
                  hideCursor.hideCursor();
                }
              }
            }
          },
        ),
        progressIndicatorDelay:
            GetPlatform.isAndroid ? const Duration(days: 1) : null,
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
        ],
        errorBuilder: errorBuilder,
        placeholder: placeholderWidget(),
      );

      // 防止全屏的 workaround
      bool workaround = true;
      chewieController!.addListener(() {
        if (mounted && chewieController != null) {
          var isFullScreen = chewieController!.isFullScreen;
          if (isFullScreen && workaround) {
            chewieController!.exitFullScreen();
            workaround = false;
            if (mounted) setState(() {});
          }
        }
      });

      // 完成初始化
      if (mounted && chewieController != null) {
        setState(() {
          isLoading = false;
        });
        print('视频加载完成: ${cx.url}');
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          chewieController = null;
          videoPlayerController = null;
        });
      }
    }
  }

  // 切换视频时，保持 loading 直到完全初始化
  Future<void> switchVideo(VideoInfo newVideo) async {
    currVideo = newVideo;
    await init(newVideo);
  }

  void openPlayList() {
    if (GetPlatform.isDesktop) {
      hideCursor.showCursor();
    }
    showCupertinoModalPopup(
      context: context,
      builder: (cx) => _buildEndDrawer(),
    );
  }

  Widget _buildEndDrawer() {
    var width = context.mediaQuery.size.width * .32;
    if (context.mediaQuery.size.width <= 720) width = 240;
    return Container(
      color: Colors.black.withValues(alpha: .42),
      width: double.infinity,
      height: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(onTap: () => Get.back()),
          ),
          Container(
            color: Colors.black.withValues(alpha: .72),
            width: width,
            height: double.infinity,
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  var item = videos[index];
                  var isCurr = currVideo == item;
                  return Material(
                    child: ListTile(
                      textColor: Colors.white,
                      selectedColor: Colors.white,
                      selectedTileColor: "#03395e".$color,
                      hoverColor: "#03395e".$color,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isCurr ? "#0078d4".$color : Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                      title: Text(item.name),
                      onTap: () async {
                        Get.back();
                        if (isCurr) return;
                        // 切换视频，保持 loading 直到完全初始化
                        await switchVideo(item);
                      },
                      selected: currVideo == item,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return _buildLoading();
                  }
                  if (chewieController != null &&
                      videoPlayerController != null) {
                    return Chewie(controller: chewieController!);
                  }
                  return _buildLoading();
                },
              ),
            ),
            if (GetPlatform.isDesktop || isLoading)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: CustomMoveWindow(
                  child: Container(
                    width: double.infinity,
                    height: 80, // 固定高度避免布局问题
                    padding: const EdgeInsets.only(top: 21),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedOpacity(
                          opacity: showTopbar ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: const CupertinoNavigationBarBackButton(
                            previousPageTitle: "返回",
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: showTopbar ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: CupertinoButton(
                            padding: const EdgeInsets.only(right: 24),
                            onPressed: () {
                              openPlayList();
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.select_all, size: 24),
                                SizedBox(width: 3),
                                Text("选集", style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          spacing: 12,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(
              radius: 18,
              color: Colors.white,
            ),
            Text(
              "加载中...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget errorBuilder(BuildContext context, String errorMessage) {
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.black.withValues(alpha: .42),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24)
              .copyWith(bottom: 12),
          width: Get.width * .72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.bolt_slash_fill, size: 88),
                  const SizedBox(height: 12),
                  const Text("播放失败", style: TextStyle(fontSize: 24)),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .72),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                color: CupertinoColors.systemRed,
                child: const Text("退出播放"),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget placeholderWidget() {
    if (cover.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black12,
        image: DecorationImage(
          fit: BoxFit.cover,
          opacity: .24,
          image: NetworkImage(cover),
        ),
      ),
    );
  }
}
