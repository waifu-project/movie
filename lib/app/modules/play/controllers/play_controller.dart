// Copyright (C) 2021 d1y <chenhonzhou@gmail.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'dart:async';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/modules/play/views/chewie_view.dart';
import 'package:movie/app/modules/play/views/webview_view.dart';
import 'package:movie/config.dart';
import 'package:movie/mirror/mirror_serialize.dart';

class PlayController extends GetxController {
  MirrorOnceItemSerialize movieItem = Get.arguments;

  HomeController home = Get.find<HomeController>();

  bool _canShowPlayTips = false;

  int tabIndex = 0;

  changeTabIndex(dynamic i) {
    tabIndex = i;
    update();
  }

  bool get canShowPlayTips {
    return _canShowPlayTips;
  }

  set canShowPlayTips(bool newVal) {
    _canShowPlayTips = newVal;
    update();
    home.localStorage.write(ConstDart.showPlayTips, newVal);
  }

  String playTips = "";

  m3u82Iframe(String m3u8) {
    return "https://dplayerx.com/m3u8.php?url=$m3u8";
  }

  String webviewShowMessage = "请勿相信广告";

  handleTapPlayerButtom(MirrorSerializeVideoInfo e) async {
    var url = e.url;
    debugPrint("play url: [$url]");

    /// https://github.com/MixinNetwork/flutter-plugins/tree/main/packages/desktop_webview_window
    /// 该插件支持 `windows` | `linux`(<然而[webview.launch]方法不支持:(>) | `macos`
    if (GetPlatform.isWindows || GetPlatform.isMacOS) {
      /// `MP4` 理论上来说不需要操作就可以直接喂给浏览器?
      if (e.type == MirrorSerializeVideoType.m3u8) url = m3u82Iframe(url);
      Webview webview = await WebviewWindow.create();

      /// 白嫖的第三方资源会自动跳转广告网站, 这个方法将延迟删除广告
      int beforeRemoveADTime = 1200;
      webview.addScriptToExecuteOnDocumentCreated(
          "alert('$webviewShowMessage');setTimeout(function() {window.removeEventListener('click', _popwnd_open);}, $beforeRemoveADTime)");
      webview.launch(url);

      return;
    }
    if (e.type == MirrorSerializeVideoType.iframe) {
      Get.to(
        () => WebviewView(),
        arguments: url,
      );
    } else if (e.type == MirrorSerializeVideoType.m3u8) {
      Get.to(
        () => ChewieView(),
        arguments: {
          'url': url,
          'cover': movieItem.smallCoverImage,
        },
      );
    }
  }

  loadAsset() async {
    var tips = await rootBundle.loadString('assets/data/play_tips.txt');
    playTips = tips;
    update();
  }

  showPlayTips() {
    var ctx = Get.context;
    if (ctx == null) return;
    showCupertinoDialog(
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('免责提示'),
        content: Text(playTips),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text(
              '不在提醒',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onPressed: () {
              canShowPlayTips = false;
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text(
              '我知道了',
              style: TextStyle(color: Colors.blue),
            ),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      context: ctx,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _canShowPlayTips =
        home.localStorage.read<bool>(ConstDart.showPlayTips) ?? true;
    update();
    if (canShowPlayTips) {
      Timer(Duration(seconds: 2), () {
        showPlayTips();
      });
    }
  }

  @override
  void onReady() {
    super.onReady();
    loadAsset();
  }

  @override
  void onClose() {}
}
