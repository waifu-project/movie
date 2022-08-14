import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'custom_play.dart';

class ChewieView extends StatefulWidget {
  const ChewieView({Key? key}) : super(key: key);

  @override
  _ChewieViewState createState() => _ChewieViewState();
}

class _ChewieViewState extends State<ChewieView> {
  late ChewieController chewieController;
  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
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

  Map<String, dynamic> get args {
    return Get.arguments;
  }

  init() {
    setState(() {
      // FIXME: 若没有传入视频地址，则报错
      videoPlayerController = VideoPlayerController.network(args["url"]);
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
      customControls: CustomCupertinoControls(
        backgroundColor: Colors.black38,
        iconColor: Colors.white,
      ),
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      errorBuilder: errorBuilder,
      placeholder: placeholderWidget,
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
            color: Colors.black.withOpacity(.42),
          ),
          padding: EdgeInsets.symmetric(
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
                  Icon(
                    CupertinoIcons.bolt_slash_fill,
                    size: 88,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    "播放失败",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.72),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              CupertinoButton(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                color: CupertinoColors.systemRed,
                child: Text("退出播放"),
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
        decoration: BoxDecoration(
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
              Image.network(
                args['cover'],
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
