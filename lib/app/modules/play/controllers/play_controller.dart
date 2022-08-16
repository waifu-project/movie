// Copyright (C) 2021-2022 d1y <chenhonzhou@gmail.com>
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
import 'package:movie/utils/helper.dart';

/// 尽可能的拿到正确`url`
/// [str] 数据模板
///  => https://xx.com/1.m3u8$sdf
///  => https://xx.com/sdfsdf&sdf
String getPlayUrl(String str) {
  /// 标识符
  List<String> sybs = ["\$", "&"];

  /// 此处标识符是比对 `sdf` 的值, 如果值中有这些内容的话还是返回原值
  /// (因为有些源比较伤脑筋)
  /// (如果某个源在这种情况下还是返回了一个 `/` 那我就真无语了。。)
  List<String> idents = [".m3u8", "/"];

  for (var i = 0; i < sybs.length; i++) {
    String current = sybs[i];
    var tagOfIndex = str.lastIndexOf(current);
    if (tagOfIndex > -1) {
      var vData = str.substring(tagOfIndex, str.length);
      bool checkDataFake = idents.any((element) => vData.contains(element));
      if (!checkDataFake) return str.substring(0, tagOfIndex);
    }
  }
  return str;
}

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
    url = getPlayUrl(url);
    debugPrint("play url: [$url]");

    /// https://github.com/MixinNetwork/flutter-plugins/tree/main/packages/desktop_webview_window
    /// 该插件支持 `windows` | `linux`(<然而[webview.launch]方法不支持:(>) | `macos`
    if (GetPlatform.isWindows || GetPlatform.isMacOS) {
      final bool typeIsM3u8 = e.type == MirrorSerializeVideoType.m3u8;

      if (GetPlatform.isMacOS && home.macosPlayUseIINA) {
        easyPlayToIINA(url);
        return;
      }

      /// `MP4` 理论上来说不需要操作就可以直接喂给浏览器?
      if (typeIsM3u8) url = m3u82Iframe(url);
      Webview webview = await WebviewWindow.create();

      /// 白嫖的第三方资源会自动跳转广告网站, 这个方法将延迟删除广告
      int beforeRemoveADTime = 1200;
      webview.addScriptToExecuteOnDocumentCreated(
          "alert('$webviewShowMessage');setTimeout(function() {window.removeEventListener('click', _popwnd_open);}, $beforeRemoveADTime)");
      webview.launch(url);

      return;
    }

    /// (`m3u8` | `mp4`) 资源
    var canUseChewieView = e.type == MirrorSerializeVideoType.m3u8 ||
        e.type == MirrorSerializeVideoType.mp4;

    /// iOS
    if (home.iosCanBeUseSystemBrowser) {
      LaunchURL(url);
      return;
    }

    if (e.type == MirrorSerializeVideoType.iframe) {
      Get.to(
        () => WebviewView(),
        arguments: url,
      );
    } else if (canUseChewieView) {
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
