import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'custom_play.dart';

class ChewieView extends StatefulWidget {
  const ChewieView({super.key});

  @override
  createState() => _ChewieViewState();
}

class _ChewieViewState extends State<ChewieView> {
  late ChewieController chewieController;
  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    initFetchUrl();
    init();
  }

  @override
  void dispose() {
    if (!chewieController.isFullScreen) {
      videoPlayerController.dispose();
      chewieController.dispose();
      super.dispose();
    }
  }

  bool initFetchUrl() {
    var args = Get.arguments ?? {};
    String url = args['url'] ?? "";
    // NOTE: 如果都没有播放地址就直接跳回到上一个页面
    if (url.isEmpty) {
      Get.back();
    }
    String cover = args['cover'] ?? "";
    if (url.isEmpty) {
      return false;
    }
    setState(() {
      playUrl = url;
      cover = cover;
    });
    return true;
  }

  String playUrl = "";
  String cover = "";

  void init() {
    setState(() {
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(playUrl),
      );
    });
    var controller = ChewieController(
      optionsTranslation: OptionsTranslation(
        playbackSpeedButtonText: '播放速度',
        cancelButtonText: "取消",
        subtitlesButtonText: "字幕",
      ),
      videoPlayerController: videoPlayerController,
      autoInitialize: true,
      autoPlay: true,
      fullScreenByDefault: true,
      showControls: true,
      showControlsOnInitialize: true,
      allowFullScreen: true,
      allowedScreenSleep: false,
      useRootNavigator: false,
      customControls: const CustomCupertinoControls(
        backgroundColor: Colors.black38,
        iconColor: Colors.white,
      ),
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      errorBuilder: errorBuilder,
      placeholder: placeholderWidget,
      additionalOptions: (_) => [
        OptionItem(
          onTap: (cx) async {
            Get.back();
            if (playUrl.isEmpty) return;
            await FlutterClipboard.copy(playUrl);
            if (GetPlatform.isAndroid) {
              Get.snackbar(
                "提示",
                "已复制到剪贴板",
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(
                  milliseconds: 1200,
                ),
              );
            }
          },
          iconData: CupertinoIcons.share,
          title: "复制视频链接",
        ),
      ],
    );

    bool isInit = true;

    setState(() {
      chewieController = controller;
      chewieController.addListener(() {
        var isFullScreen = chewieController.isFullScreen;
        if (isFullScreen && isInit) {
          chewieController.exitFullScreen();
          setState(() {
            isInit = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // XXX: `chewie` 实际上只支持 `Android` | `iOS`
      body: SafeArea(
        child: Chewie(
          controller: chewieController,
        ),
      ),
    );
  }

  Widget errorBuilder(BuildContext context, String errorMessage) {
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.black.withValues(alpha: .42),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ).copyWith(
            bottom: 12,
          ),
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
                  const Icon(
                    CupertinoIcons.bolt_slash_fill,
                    size: 88,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    "播放失败",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .72),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
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

  Widget get placeholderWidget {
    return Center(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black12,
        ),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15,
            sigmaY: 15,
          ),
          child: Stack(
            children: [
              if (cover.isNotEmpty)
                Image.network(
                  cover,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
