import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:catmovie/app/modules/play/views/chewie_view.dart';
import 'package:catmovie/app/modules/play/views/play_view.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/modules/home/views/source_help.dart';
import 'package:catmovie/app/modules/play/views/webview_view.dart';
import 'package:catmovie/shared/auto_injector.dart';
import 'package:media_kit/media_kit.dart';
import 'package:xi/xi.dart';
import 'package:catmovie/isar/schema/parse_schema.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:webplayer_embedded/webplayer_embedded.dart';

// 延迟注入播放列表的时间
const kDelayExecInjectPlaylistJSCode = Duration(seconds: 1);

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
  VideoDetail movieItem = Get.arguments;

  WebPlayerEmbedded webPlayerEmbedded = autoInjector.get<WebPlayerEmbedded>();

  HomeController home = Get.find<HomeController>();

  ISpiderAdapter get currentMovieInstance {
    var itemAs = home.currentMirrorItem;
    return itemAs;
  }

  PlayState playState = kEmptyPlayState;

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

  void changeTabIndex(dynamic i) {
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

  HttpServer? _httpServerContext;

  String url2Iframe(String realUrl, HttpServer server) {
    var type = getSettingAsKeyIdent<IWebPlayerEmbeddedType>(
      SettingsAllKey.webviewPlayType,
    );
    if (realUrl.endsWith(".m3u8")) {
      return webPlayerEmbedded.generatePlayerUrl(type, realUrl);
    }
    var port = server.port;
    return "http://localhost:$port/assets/iframe.html?url=$realUrl";
  }

  Future<String> injectPlaylistJSCode(
    List<VideoInfo> playlist,
    int withTop,
  ) async {
    String playlistJS = await rootBundle.loadString(
      'assets/data/playlist.js',
    );
    String appendEvalCode = "\nconst \$data = [\n";
    for (var item in playlist) {
      appendEvalCode += "{ title:`${item.name}`, url: `${item.url}` },";
    }
    appendEvalCode += "]\n";
    appendEvalCode += "setPlaylist(\$data)\n";
    var result = """
document.addEventListener('DOMContentLoaded', function() {
  const paddingTop = $withTop
  $playlistJS
  $appendEvalCode
})
""";
    return result;
  }

  void updatePlayState(int tabIndex, int index) {
    playState = PlayState(tabIndex, index);
    update();
  }

  Future<bool> playWithWebview(
    List<VideoInfo> playList,
    VideoInfo curr,
    String url,
  ) async {
    if (GetPlatform.isWindows) {
      bool bWebviewWindow = await WebviewWindow.isWebviewAvailable();
      if (!bWebviewWindow) {
        await showCupertinoDialog(
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
                    color: Color.fromARGB(255, 51, 22, 20),
                  ),
                ),
                onPressed: () {
                  Get.back();
                },
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  _kWindowsWebviewRuntimeLink.openURL();
                  Get.back();
                },
                child: const Text(
                  '去下载',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              )
            ],
          ),
          context: Get.context as BuildContext,
        );
        return false;
      }
    }

    Webview webview = await WebviewWindow.create(
      configuration: CreateConfiguration(
        titleBarHeight: GetPlatform.isMacOS ? 24 : 0,
        title: "小猫影视",
      ),
    );

    void setWebviewActivePlay(VideoInfo curr) {
      webview.evaluateJavaScript("setActionText(`${curr.name}`)");
      webview.evaluateJavaScript("setActiveWithPlaylist(`${curr.url}`)");
    }

    void updatePlayStateWithUrl(String url) {
      int index = playList.indexWhere(
        (item) => item.url == url,
      );
      if (index >= 0) {
        updatePlayState(tabIndex, index);
      }
    }

    /// `MP4` 理论上来说不需要操作就可以直接喂给浏览器?
    if (!(await webPlayerEmbedded.checkRunning())) {
      _httpServerContext = await webPlayerEmbedded.createServer(
        onMessage: (msg) {
          String value = jsonDecode(msg.value);
          switch (msg.type) {
            case "switchVideo":
              updatePlayStateWithUrl(value);
          }
        },
      );
    }

    url = url2Iframe(url, _httpServerContext!);
    debugPrint("webview url: $url");
    // NOTE(d1y): linux 不支持?
    webview.launch(url);

    // (不需要解析)白嫖的第三方资源会自动跳转广告网站, 这个方法将延迟删除广告
    // NOTE(d1y): 果真需要吗?
    // if (!needParse) {
    //   int beforeRemoveADTime = 1200;
    //   String execCode =
    //       "alert('$webviewShowMessage');setTimeout(function() {window.removeEventListener('click', _popwnd_open);}, $beforeRemoveADTime)";
    //   webview.addScriptToExecuteOnDocumentCreated(execCode);
    // }

    webview.setOnUrlRequestCallback((newUrl) {
      updatePlayStateWithUrl(newUrl);
      Future.delayed(kDelayExecInjectPlaylistJSCode, () async {
        var curr = playList.firstWhere((element) => element.url == newUrl);
        setWebviewActivePlay(curr);
      });
      return true;
    });

    if (playList.length >= 2) {
      webview.addScriptToExecuteOnDocumentCreated(
        await injectPlaylistJSCode(playList, GetPlatform.isMacOS ? 0 : 12),
      );
      Future.delayed(kDelayExecInjectPlaylistJSCode, () async {
        setWebviewActivePlay(curr);
      });
    }
    return true;
  }

  Future<String> parseIframe(String iframe) async {
    var closed = showLoading("正在解析iframe");
    var result = await home.currentMirrorItem.parseIframe(iframe);
    closed();
    if (result.isEmpty) {
      EasyLoading.showError("解析失败, 无法播放");
      return "";
    }
    debugPrint("result: $result");
    String url = result[0]; // NOTE(d1y): 估计解析到不止一个, 该用哪一个呢!
    return url;
  }

  Future<bool> handleTapPlayerButtom(
    VideoInfo curr,
    List<VideoInfo> playList,
    int tabIndex,
    VideoKernel videoKernel,
    Player mediaKitPlayer,
  ) async {
    var url = curr.url;
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
      return false;
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

    debugPrint("current play url is: $url");

    switch (videoKernel) {
      case VideoKernel.webview:
        if (GetPlatform.isDesktop) {
          return await playWithWebview(playList, curr, url);
        } else {
          if (GetPlatform.isAndroid) {
            if (curr.type == VideoType.iframe) {
              Get.to(
                () => const WebviewView(),
                arguments: url,
              );
            } else {
              Get.to(
                () => const ChewieView(),
                arguments: {
                  'url': url,
                  'cover': movieItem.smallCoverImage,
                },
              );
            }
          } else {
            if (curr.type == VideoType.iframe) {
              url = await parseIframe(url);
              if (url.isEmpty) return false;
            }
            url.openURL();
          }
        }
        break;
      case VideoKernel.iina:
        if (!GetPlatform.isMacOS) {
          EasyLoading.showError("该平台不支持 iina 播放");
          return false;
        }
        if (curr.type == VideoType.iframe) {
          url = await parseIframe(url);
          if (url.isEmpty) return false;
        }
        url.openToIINA();
        break;
      case VideoKernel.mediaKit:
        if (curr.type == VideoType.iframe) {
          url = await parseIframe(url);
          if (url.isEmpty) return false;
        }
        mediaKitPlayer.open(Media(url));
        break;
    }

    return true;
  }

  Future<void> loadAsset() async {
    var tips = await rootBundle.loadString('assets/data/play_tips.txt');
    playTips = tips;
    update();
  }

  void showPlayTips() {
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
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              '我知道了',
              style: TextStyle(color: Colors.blue),
            ),
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
