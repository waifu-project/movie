import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:movie/app/widget/window_appbar.dart';
import 'package:movie/utils/screen_helper.dart';
import 'package:video_player/video_player.dart';

class ChewieView extends StatefulWidget {
  const ChewieView({Key? key}) : super(key: key);

  @override
  _ChewieViewState createState() => _ChewieViewState();
}

class _ChewieViewState extends State<ChewieView> {
  late VideoPlayerController videoPlayerController;

  late ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    execScreenDirction(ScreenDirction.x);
    initializePlayer();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    execScreenDirction(ScreenDirction.y);
    super.dispose();
  }

  Map<String, dynamic> get args {
    return Get.arguments;
  }

  /// NOTE:
  ///   => 返回一个 `future`
  initializePlayer() async {
    videoPlayerController = VideoPlayerController.network(
      args['url'],
    );
    await videoPlayerController.initialize();
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      customControls: CupertinoControls(
        backgroundColor: Colors.black38,
        iconColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WindowAppBar(
        iosBackStyle: true,
      ),
      body: Chewie(
        controller: ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: true,
          customControls: CupertinoControls(
            backgroundColor: Colors.black38,
            iconColor: Colors.white,
          ),
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown
          ],
          placeholder: BackdropFilter(
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
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 15,
                      sigmaY: 15,
                    ),
                    child: Container(
                      color: Colors.white10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
