import 'dart:async';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:movie/app/extension.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/modules/home/views/source_help.dart';
import 'package:movie/app/modules/play/views/chewie_view.dart';
import 'package:movie/app/modules/play/views/webview_view.dart';
import 'package:movie/shared/auto_injector.dart';
import 'package:movie/spider/abstract/spider_movie.dart';
import 'package:movie/isar/schema/parse_schema.dart';
import 'package:movie/spider/impl/mac_cms.dart';
import 'package:movie/spider/abstract/spider_serialize.dart';
import 'package:movie/shared/enum.dart';
import 'package:movie/utils/helper.dart';
import 'package:webplayer_embedded/webplayer_embedded.dart';

// https://www.bilibili.com/video/BV1cN411d73g
//
// 嗷！我们是斗鱼直播间6324抽象工作室，
// 我是抽象工作室李赣，
// 我是抽象工作室的大师兄，
// 我是抽象工作室的劳改犯。
// 在新的一年里，
// 抽象工作室祝广大斗鱼水友新年快乐。
//
// 如果能够重来, 你还会在那天下午打开一个房间号为 6324 的直播间吗?
const kWebPlayerEmbeddedPort = 6324;

const _kWindowsWebviewRuntimeLink =
    "https://developer.microsoft.com/en-us/microsoft-edge/webview2";

/// 需要解析的链接集合
const _kNeedToParseDomains = [
  "www.iqiyi.com",
  "v.qq.com",
  "youku.com",
  "www.le.com",
  "mgtv.com",
  "sohu.com",
  "acfun.cn",
  "bilibili.com",
  "baofeng.com",
  "pptv.com",
  "1905.com",
  "miguvideo.com",
  'm.bilibili.com',
  'www.youku.com',
  'm.youku.com',
  'v.youku.com',
  'm.v.qq.com',
  'm.iqiyi.com',
  'm.mgtv.com',
  'www.mgtv.com',
  'm.tv.sohu.com',
  'm.1905.com',
  'm.pptv.com',
  'm.le.com'
];
const _kHttpPrefix = "http://";
const _kHttpsPrefix = "https://";

/// 检测是否需要解析
bool checkDomainIsParse(String raw) {
  for (var i = 0; i < _kNeedToParseDomains.length; i++) {
    var curr = _kNeedToParseDomains[i];
    var p1 = _kHttpPrefix + curr;
    var p2 = _kHttpsPrefix + curr;
    var check = raw.startsWith(p1) || raw.startsWith(p2);
    if (check) return true;
  }
  return false;
}

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

String easyGenParseVipUrl(String raw, ParseIsarModel model) {
  String url = model.url;
  String result = '$url$raw';
  return result;
}

class PlayController extends GetxController {
  MirrorOnceItemSerialize movieItem = Get.arguments;

  WebPlayerEmbedded webPlayerEmbedded = autoInjector.get<WebPlayerEmbedded>();

  HomeController home = Get.find<HomeController>();

  ISpider get currentMovieInstance {
    var itemAs = home.currentMirrorItem;
    return itemAs;
  }

  /// 是否为通用解析
  bool get bIsBaseMirrorMovie {
    return currentMovieInstance is MacCMSSpider;
  }

  /// 是否可以解析
  bool get canTryParseVip {
    var listTotal = home.parseVipList.length;
    var currIndex = home.currentBarIndex;
    var wrapperIf = listTotal >= 1 && currIndex >= 0;

    /// 通用扩展源才具备所谓的解析
    /// > 源包括 [ 自实现源, 通用扩展源 ]
    /// >> 自实现源不是继承的 `KBaseMirrorMovie`
    if (bIsBaseMirrorMovie) {
      /// NOTE: 当前实例有解析地址, 并且无边界情况
      var instance = currentMovieInstance as MacCMSSpider;
      var jiexiUrl = instance.jiexiUrl;
      bool next = jiexiUrl.isNotEmpty || wrapperIf;
      return next;
    }

    return wrapperIf;
  }

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
    updateSetting(SettingsAllKey.showPlayTips, newVal);
  }

  String playTips = "";

  m3u82Iframe(String m3u8) {
    var type = getSettingAsKeyIdent<IWebPlayerEmbeddedType>(
      SettingsAllKey.webviewPlayType,
    );
    var url = webPlayerEmbedded.generatePlayerUrl(type, m3u8);
    return url;
  }

  String webviewShowMessage = "请勿相信广告";

  handleTapPlayerButtom(MirrorSerializeVideoInfo e) async {
    var url = e.url;
    url = getPlayUrl(url);

    /// NOTE: 解析条件
    /// - 通过比对 `_kNeedToParseDomains` 是否需要解析
    /// - 是否是通用扩展源(未完成!!)
    bool needParse = checkDomainIsParse(url);

    /// NOTE: 是否弹出无解析提示, 需同时具备:
    /// 1. 需要解析
    /// 2. 是否可以解析
    bool bWarnShowNotParse = needParse && !canTryParseVip;
    if (bWarnShowNotParse) {
      showEasyCupertinoDialog(
        title: '提示',
        content: '暂不支持需要解析的播放链接(无线路)',
        confirmText: '我知道了',
        onDone: () {
          Get.back();
        },
      );
      return;
    }

    if (needParse) {
      var instance = currentMovieInstance as MacCMSSpider;

      /// !! 如果当前节点有解析接口优先使用
      /// > 反之将使用自用节点(即`解析线路管理`)
      /// !!!! TODO: 解析接口优先级暂无法控制
      if (instance.hasJiexiUrl) {
        url = instance.jiexiUrl + url;
      } else {
        var modelData = home.currentParseVipModelData;
        if (modelData != null) {
          url = easyGenParseVipUrl(url, modelData);
        }
      }
    }

    debugPrint("play url: [$url]");

    bool isWindows = GetPlatform.isWindows;
    bool isMacos = GetPlatform.isMacOS;

    /// https://github.com/MixinNetwork/flutter-plugins/tree/main/packages/desktop_webview_window
    /// 该插件支持 `windows` | `linux`(<然而[webview.launch]方法不支持:(>) | `macos`
    if (isWindows || isMacos) {
      final bool typeIsM3u8 = e.type == MirrorSerializeVideoType.m3u8;

      if (isMacos && home.macosPlayUseIINA) {
        easyPlayToIINA(url);
        return;
      }

      if (isWindows) {
        bool bWebviewWindow = await WebviewWindow.isWebviewAvailable();
        if (!bWebviewWindow) {
          showCupertinoDialog(
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: const Text('提示'),
              content: const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 12.0,
                ),
                child: Text(
                  '未安装 edge webview runtime, 无法播放 :(',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: const Text(
                    '我知道了',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                ),
                CupertinoDialogAction(
                  child: const Text(
                    '去下载',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  isDestructiveAction: true,
                  onPressed: () {
                    LaunchURL(_kWindowsWebviewRuntimeLink);
                    Get.back();
                  },
                )
              ],
            ),
            context: Get.context as BuildContext,
          );
          return;
        }
      }

      /// `MP4` 理论上来说不需要操作就可以直接喂给浏览器?
      if (typeIsM3u8) {
        if (!(await webPlayerEmbedded.checkRunning())) {
          await webPlayerEmbedded.createServer(port: kWebPlayerEmbeddedPort);
        }
        url = m3u82Iframe(url);
      }
      Webview webview = await WebviewWindow.create();

      /// (不需要解析)白嫖的第三方资源会自动跳转广告网站, 这个方法将延迟删除广告
      if (!needParse) {
        int beforeRemoveADTime = 1200;
        String execCode =
            "alert('$webviewShowMessage');setTimeout(function() {window.removeEventListener('click', _popwnd_open);}, $beforeRemoveADTime)";
        webview.addScriptToExecuteOnDocumentCreated(execCode);
      }

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
        () => const WebviewView(),
        arguments: url,
      );
    } else if (canUseChewieView) {
      Get.to(
        () => const ChewieView(),
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
    _canShowPlayTips = getSettingAsKeyIdent<bool>(SettingsAllKey.showPlayTips);
    update();
    if (canShowPlayTips) {
      Timer(const Duration(seconds: 2), () {
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
