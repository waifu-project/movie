import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/widget/k_body.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hide_cursor/hide_cursor.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:tuple/tuple.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xi/xi.dart';

// https://github.com/hoangnx2204/m3u_utils
class M3uUtils {
  static Tuple2<String, String> beautiProp(String propInput) {
    final String prop =
        propInput.replaceAll('"', '').replaceAll('\'', '').trim();
    final List<String> propSplit = prop.split('=');
    return Tuple2(propSplit.first, propSplit.sublist(1).join('='));
  }

  static Map<String, dynamic> parse(String m3u) {
    final Map<String, dynamic> output = {'items': [], 'total': 0};
    List<String> m3uSplit = m3u.split('#EXTINF:');
    final String title = m3uSplit.removeAt(0);
    final List<String> titleProps = title.split('\n').first.split(' ');
    for (String prop in titleProps) {
      if (prop.contains('=')) {
        prop = prop.replaceAll('"', '');
        prop = prop.replaceAll('\'', '');
        final data = prop.split('=');
        output.update(
          data.first.trim(),
          (_) => data.last.trim(),
          ifAbsent: () => data.last.trim(),
        );
      }
    }

    for (String part in m3uSplit) {
      final Map<String, dynamic> item = {'urls': []};
      final List<String> lines = part.split('\n');

      for (var line in lines) {
        final bool isMeta =
            RegExp(r'^[-,\d]').hasMatch(line) && line.contains(',');
        if (isMeta) {
          final List<String> lineSplit = line.split(',');
          final List<String> props = lineSplit.first.split(' ');
          final num duration = num.tryParse(props.removeAt(0)) ?? 0;
          final List<String> namedProps = props.join(" ").split('" ')
            ..removeWhere((element) => element.isEmpty);
          item.addAll({
            'name': lineSplit.lastOrNull?.trim() ?? '',
            'duration': duration,
            for (var prop in namedProps)
              beautiProp(prop).item1: beautiProp(prop).item2
          });
        } else {
          if (line.contains('://')) {
            item['urls'].add(line.trim());
          }
        }
      }
      output['items'].add(item);
    }
    output['total'] = (output['items'] as List).length;

    return output;
  }
}

int generateRandomInt(int length) {
  final random = Random();
  int min = pow(10, length - 1).toInt();
  int max = pow(10, length).toInt() - 1;
  return min + random.nextInt(max - min + 1);
}

class TabToggle extends Intent {}

// TODO(d1y): support dynamic color
final Color kActiveColor = Color(0xFF6750A4);

var scaffoldKey = GlobalKey<ScaffoldState>();

// TODO(d1y): support dynamic set wallpaper
// https://www.zichen.zone/archives/acg-api.html
final String kWallpaper = "https://www.dmoe.cc/random.php";

enum LiveSourceType {
  github,
  full,
}

/// [0] => 名称(如果类型是 Github, 则也为Repo链接)
/// [1] => 链接(如果类型是 Github, 则也为Repo-path)
/// [2] => 类型(不为Github则为全量链接)
/// [3] => 其他内容(可能包含分支等信息)
typedef LiveSourceLinkType
    = Tuple4<String, String, LiveSourceType, Map<String, String>>;

// TODO(d1y): support dynamic use live sources
final List<LiveSourceLinkType> kLiveSources = [
  // https://github.com/vbskycn/iptv
  Tuple4(
    "vbskycn/iptv",
    "tv/iptv4.m3u",
    LiveSourceType.github,
    {"branch": "master"},
  ),
  // https://github.com/kimwang1978/collect-tv-txt
  // 这个直播源好像不错🤔?
  Tuple4(
    "kimwang1978/collect-tv-txt",
    "bbxx_lite.m3u",
    LiveSourceType.github,
    {"branch": "main"},
  ),
  // https://github.com/Guovin/iptv-api
  Tuple4(
    "Guovin/iptv-api",
    "output/ipv4/result.m3u",
    LiveSourceType.github,
    {"branch": "gd"},
  ),
  // https://github.com/hujingguang/ChinaIPTV
  // TODO(d1y): 支持解析 m3u8
  // Tuple4(
  //   "hujingguang/ChinaIPTV",
  //   "cnTV_AutoUpdate.m3u8",
  //   LiveSourceType.github,
  //   {"branch": "main"},
  // ),
  // https://github.com/TianmuTNT/iptv
  Tuple4(
    "TianmuTNT/iptv",
    "iptv.m3u",
    LiveSourceType.github,
    {"branch": "main"},
  ),
  // https://github.com/mytv-android/China-TV-Live-M3U8
  Tuple4(
    "mytv-android/China-TV-Live-M3U8",
    "iptv.m3u",
    LiveSourceType.github,
    {"branch": "main"},
  ),
  // https://tv.iill.top
  // Tuple4("大葱直播(电视)", "https://tv.iill.top/m3u/Gather", LiveSourceType.full, {}),
  // Tuple4("大葱直播(网络)", "https://tv.iill.top/m3u/Live", LiveSourceType.full, {}),
  // https://iptv.hacks.tools
  // https://github.com/xfcjp/xfcjp.github.io
  // ↑↑↑↑↑↑ 这些怎么样?
];

var kVideoFits = LinkedHashMap<BoxFit, String>.from({
  BoxFit.contain: "适应",
  BoxFit.fill: "拉伸",
  BoxFit.cover: "填充",
});

class TV {
  const TV({
    required this.name,
    required this.url,
    required this.id,
    required this.logo,
    required this.groupName,
  });
  final int id;
  final String name;
  final String url;
  final String? logo;
  final String groupName;
}

class Group {
  final String name;
  final List<TV> tvs;

  Group({required this.name, this.tvs = const []});
  void addTV(String tvName, String tvUrl, {String? logo, int? id}) {
    var realId = id ?? generateRandomInt(6);
    var tv = TV(
      name: tvName,
      groupName: name,
      url: tvUrl,
      logo: logo,
      id: realId,
    );
    tvs.add(tv);
  }
}

class Groups {
  Map<String, List<TV>> tvs = {};
  void addTv(
    String groupName,
    String tvName,
    String tvUrl, {
    String? logo,
    int? id,
  }) {
    if (!tvs.containsKey(groupName)) {
      tvs[groupName] = [
        TV(
          name: tvName,
          groupName: groupName,
          url: tvUrl,
          logo: logo,
          id: id ?? generateRandomInt(6),
        )
      ];
    } else {
      tvs[groupName]!.add(
        TV(
          name: tvName,
          groupName: groupName,
          url: tvUrl,
          logo: logo,
          id: id ?? generateRandomInt(6),
        ),
      );
    }
  }

  void merge(Groups other) {
    for (var key in other.tvs.keys) {
      if (!tvs.containsKey(key)) {
        tvs[key] = other.tvs[key]!;
      } else {
        tvs[key]!.addAll(other.tvs[key]!);
      }
    }
  }

  List<String> get names => tvs.keys.toList();
}

class Loader {
  static final urlReg = RegExp(
      r'(((ht|f)tps?):\/\/)?([^!@#$%^&*?.\s-]([^!@#$%^&*?.\s]{0,63}[^!@#$%^&*?.\s])?\.)+[a-z]{2,6}\/?');

  static Groups parseM3u(String rawM3uTxt) {
    var groups = Groups();
    var map = M3uUtils.parse(rawM3uTxt);
    var items = map['items'] ?? [];
    for (var item in items) {
      int id = int.tryParse(item['tvg-id'] ?? "") ?? generateRandomInt(6);
      List<String> _url = (item['urls'] ?? [""]).cast<String>();
      if (_url.isEmpty) {
        _url.add("");
      }
      String url = _url[0];
      groups.addTv(
        item['group-title'] ?? "未分类",
        item['name'] ?? "",
        url,
        id: id,
        logo: item['tvg-logo'] ?? "",
      );
    }
    return groups;
  }

  static Groups parseTxt(String rawTxt) {
    var groups = Groups();
    var lines = rawTxt.split("\n");
    var currKey = "";
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        currKey = "";
        continue;
      }
      var cxx = line.split(",");
      if (!urlReg.hasMatch(line) && currKey.isEmpty) {
        currKey = cxx[0];
        continue;
      }
      if (currKey.isEmpty || cxx.length != 2) continue;
      groups.addTv(currKey, cxx[0], cxx[1]);
    }
    return groups;
  }
}

class LiveSource {
  final String name;
  final String url;
  final int id;
  LiveSource({
    required this.name,
    required this.url,
    required this.id,
  });
}

class LiveSourceGroups {
  /// 使用 https://ghproxy.link 加速
  final String _kGithubFastDomain = "https://ghfast.top";

  String _2url(LiveSourceLinkType cx, bool githubFast) {
    if (cx.item3 == LiveSourceType.github) {
      var map = cx.item4;
      String branch = map["branch"]!;
      var rawGithubUrl =
          "https://raw.githubusercontent.com/${cx.item1}/refs/heads/$branch/${cx.item2}";
      if (githubFast) return "$_kGithubFastDomain/$rawGithubUrl";
      return rawGithubUrl;
    }
    return cx.item2;
  }

  LiveSourceGroups.withInit() {
    for (var cx in kLiveSources) {
      add(cx.item1, _2url(cx, false));
    }
  }

  List<LiveSource> sources = [];

  Map<LiveSource, Groups> map = {};

  bool hasSource(LiveSource source) {
    return map.containsKey(source);
  }

  Groups? getGroups(LiveSource source) {
    return map[source];
  }

  void add(String name, String url) {
    sources.add(
      LiveSource(
        name: name,
        url: url,
        id: generateRandomInt(6),
      ),
    );
  }

  Future<bool> refreshSource(LiveSource source) async {
    try {
      var resp = await XHttp.dio.get<String>(
        source.url,
        // NOTE(d1y): 我想我们在这里不需要缓存!
        options: $noCacheOption(),
      );
      String body = resp.data ?? "";
      if (body.isEmpty) return false;
      late Groups groups;
      if (source.url.endsWith(".m3u")) {
        groups = Loader.parseM3u(body);
      } else {
        // TODO(d1y): support more format
        if (source.url.endsWith(".txt")) {
          groups = Loader.parseTxt(body);
        }
      }
      map[source] = groups;
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}

class TVUI extends StatefulWidget {
  const TVUI({super.key});

  @override
  State<TVUI> createState() => TVUIState();
}

class TVUIState extends State<TVUI>
    with AfterLayoutMixin<TVUI>, WindowListener {
  late final Player player = Player();
  late final controller = VideoController(player);
  final focusNode = FocusNode();

  Timer? _autoHideCursorTimer;

  void autoHideCursor() {
    if (GetPlatform.isMobile) return;
    _autoHideCursorTimer?.cancel();
    _autoHideCursorTimer = Timer(kAutoHideCursorDuration, () {
      hideCursor.hideCursor();
    });
  }

  void hijackAutoHideCursor(dynamic _) {
    if (GetPlatform.isMobile) return;
    _autoHideCursorTimer?.cancel();
    hideCursor.showCursor();
    bool hasDrawer = scaffoldKey.currentState?.hasDrawer ?? false;
    if (showVideoControls || hasDrawer) {
      return;
    }
    autoHideCursor();
  }

  final HomeController homeController = Get.find<HomeController>();

  LiveSourceGroups liveSourceGroups = LiveSourceGroups.withInit();

  LiveSource? currLiveSource;

  // TODO(d1y): 将这部分转移到 sourceGroups 里
  Groups groups = Groups();
  String currGroupName = "";
  String realURL = "";
  int currTVIdx = -1;

  BoxFit videoFit = kVideoFits.keys.first;

  bool showVideoControls = false;

  bool showPlayPauseIcon = false;
  Timer? _playPauseIconTimer;

  void _showPlayPauseIconForDuration(
      [Duration duration = const Duration(milliseconds: 800)]) {
    setState(() {
      showPlayPauseIcon = true;
    });
    _playPauseIconTimer?.cancel();
    _playPauseIconTimer = Timer(duration, () {
      if (mounted) {
        setState(() {
          showPlayPauseIcon = false;
        });
      }
    });
  }

  List<TV> get currTVS {
    if (groups.tvs.containsKey(currGroupName)) {
      return groups.tvs[currGroupName]!;
    }
    return [];
  }

  void playURL(String url, {isCloseDrawer = true, isWait = true}) async {
    if (url.isEmpty) return;
    realURL = url;
    setState(() {});
    player.open(Media(url));
    if (isCloseDrawer) {
      if (isWait) await Future.delayed(const Duration(milliseconds: 420));
      scaffoldKey.currentState?.closeDrawer();
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _playPauseIconTimer?.cancel();
    player.dispose().catchError((error) {
      debugPrint("player dispose error: $error");
    });
    if (GetPlatform.isDesktop) {
      hideCursor.showCursor();
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void initState() {
    if (GetPlatform.isDesktop) {
      windowManager.addListener(this);
    }
    super.initState();
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    initData();
    if (GetPlatform.isDesktop) hideCursor.showCursor();
    focusNode.requestFocus();
  }

  @override
  void onWindowEnterFullScreen() {
    homeController.setBottomNavigationBar(false);
  }

  @override
  void onWindowLeaveFullScreen() {
    homeController.setBottomNavigationBar(true);
  }

  void initData() async {
    var isSuccess = await liveSourceGroups.refreshSource(
      liveSourceGroups.sources.first,
    );
    if (!isSuccess) return;
    selectLiveSourceGroup(liveSourceGroups.sources.first);
  }

  void resetCurrGroupState() {
    groups = Groups();
    currGroupName = "";
    realURL = "";
    currTVIdx = -1;
    setState(() {});
  }

  void selectLiveSourceGroup(LiveSource liveSource) async {
    resetCurrGroupState();
    currLiveSource = liveSource;
    setState(() {});
    late Groups realGroups;
    var _groups = liveSourceGroups.getGroups(liveSource);
    if (_groups == null) {
      var isSuccess = await liveSourceGroups.refreshSource(liveSource);
      if (!isSuccess) return;
      realGroups = liveSourceGroups.getGroups(liveSource)!;
    } else {
      realGroups = _groups;
    }
    groups = realGroups;
    setState(() {});
  }

  void toggleDrawer() {
    if (scaffoldKey.currentState?.hasDrawer ?? false) {
      scaffoldKey.currentState?.openDrawer();
    } else {
      scaffoldKey.currentState?.closeDrawer();
    }
  }

  // NOTE(d1y): 在桌面端需要能够拖动窗口
  Widget _buildDesktopCTRL() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: CustomMoveWindow(
        child: SizedBox(
          width: double.infinity,
          height: 42,
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    bool isDesktop = context.mediaQuery.size.width >= 600;
    double width = currTVIdx >= 0 ? 480 : 240;
    if (context.mediaQuery.size.width < 600) {
      width = 600;
    }
    return Drawer(
      width: width,
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: context.mediaQuery.padding.bottom,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.38)
                        : Colors.white.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.21),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(children: [
                        Expanded(
                          flex: isDesktop ? 6 : 4,
                          child: Column(
                            children: [
                              Expanded(
                                child: SmoothListView.builder(
                                  duration: kSmoothListViewDuration,
                                  itemCount: groups.names.length,
                                  itemBuilder: (cx, idx) {
                                    var name = groups.names[idx];
                                    var isSelected = currGroupName == name;
                                    return Material(
                                      color: Colors.transparent,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                          vertical: 1,
                                        ).copyWith(
                                          top: idx == 0 ? 24 : 1,
                                        ),
                                        child: Zoom(
                                          child: ListTile(
                                            dense: true,
                                            selected: isSelected,
                                            selectedTileColor: kActiveColor,
                                            hoverColor: Colors.white
                                                .withValues(alpha: 0.1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            title: Text(
                                              name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            onFocusChange: (flag) {
                                              currGroupName = name;
                                              currTVIdx = 0;
                                              setState(() {});
                                              if (currTVS.isNotEmpty) {
                                                playURL(currTVS[0].url);
                                              }
                                            },
                                            onTap: () {
                                              currGroupName = name;
                                              currTVIdx = 0;
                                              setState(() {});
                                              if (currTVS.isNotEmpty) {
                                                playURL(currTVS[0].url,
                                                    isCloseDrawer: false);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (!isDesktop)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(
                                      bottom: 12, left: 12, right: 12),
                                  child: CupertinoButton.filled(
                                    sizeStyle: CupertinoButtonSize.small,
                                    color: '#3e3e3e'.$color,
                                    child: Text(
                                      "关闭",
                                      style: TextStyle(
                                        color: '#767579'.$color,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      scaffoldKey.currentState?.closeDrawer();
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (currTVIdx >= 0)
                          Container(
                            width: 1,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: isDesktop ? 0.18 : .42),
                            ),
                          ),
                        if (currTVIdx >= 0)
                          Expanded(
                            flex: isDesktop ? 9 : 6,
                            child: SmoothListView.builder(
                              duration: kSmoothListViewDuration,
                              itemCount: currTVS.length,
                              itemBuilder: (cx, idx) {
                                var tv = currTVS[idx];
                                var isSelected = currTVIdx == idx;
                                return Material(
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                      vertical: 3,
                                    ).copyWith(
                                      top: idx == 0 ? 24 : 1,
                                    ),
                                    child: Zoom(
                                      child: ListTile(
                                        dense: true,
                                        contentPadding:
                                            EdgeInsets.only(left: 12),
                                        selected: isSelected,
                                        selectedTileColor: kActiveColor,
                                        hoverColor:
                                            Colors.white.withValues(alpha: 0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        title: Text(
                                          tv.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        leading: CachedNetworkImage(
                                          width: 48,
                                          height: double.infinity,
                                          imageUrl: tv.logo!,
                                          errorWidget: (_, __, ___) => Icon(
                                            Icons.live_tv,
                                            size: 32,
                                          ),
                                          placeholder: (_, __) => Center(
                                            child: CupertinoActivityIndicator(),
                                          ),
                                        ),
                                        onTap: () {
                                          currTVIdx = idx;
                                          setState(() {});
                                          playURL(tv.url);
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveSourceButton(PullDownMenuButtonBuilder button) {
    return Zoom(
      child: PullDownButton(
        buttonBuilder: button,
        itemBuilder: (cx) {
          return liveSourceGroups.sources.map((item) {
            var selected = currLiveSource == item;
            var name = item.name;
            String? subTitle;
            if (name.contains("/")) {
              var parts = name.split("/");
              name = parts[0];
              subTitle = parts[1];
            }
            return PullDownMenuItem.selectable(
              onTap: () {
                selectLiveSourceGroup(item);
              },
              selected: selected,
              title: name,
              subtitle: subTitle,
              icon: Icons.live_tv,
              iconColor: CupertinoColors.systemGreen.resolveFrom(context),
            );
          }).toList();
        },
      ),
    );
  }

  // https://pub.dev/packages/video_viewer
  Widget _buildVideoControls(VideoState state) {
    state.widget.controller.player.state.playing;
    bool isDesktop = context.mediaQuery.size.width >= 600;
    return Stack(
      children: [
        Center(
          child: StreamBuilder<bool>(
            stream: state.widget.controller.player.stream.buffering,
            initialData: state.widget.controller.player.state.buffering,
            builder: (_, cx) {
              var isNext = (cx.data ?? false) && !showPlayPauseIcon;
              return AnimatedOpacity(
                opacity: isNext ? 1 : 0,
                duration: const Duration(milliseconds: 210),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
        Center(
          child: AnimatedOpacity(
            opacity: showPlayPauseIcon ? 1 : 0,
            duration: const Duration(milliseconds: 210),
            child: PlayPauseAnimatedIcon(
              size: 52,
              playing: state.widget.controller.player.state.playing,
            ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (GetPlatform.isDesktop) {
                _autoHideCursorTimer?.cancel();
                hideCursor.showCursor();
              }
              var next = !showVideoControls;
              showVideoControls = next;
              setState(() {});
              if (!next) {
                autoHideCursor();
              }
            },
            onDoubleTap: () async {
              if (GetPlatform.isDesktop) {
                _autoHideCursorTimer?.cancel();
                hideCursor.showCursor();
              }
              _showPlayPauseIconForDuration();
              state.widget.controller.player.playOrPause();
              if (!showVideoControls) {
                autoHideCursor();
              }
            },
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerMove: hijackAutoHideCursor,
              onPointerHover: hijackAutoHideCursor,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SizedBox.expand(),
              ),
            ),
          ),
        ),
        if (isDesktop)
          AnimatedPositioned(
            right: 12,
            left: 12,
            top: showVideoControls ? 24 : -72,
            duration: const Duration(milliseconds: 210),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNowLiveTV(),
                Row(
                  spacing: 12,
                  children: [
                    _buildLiveSourceButton((_, showMenu) {
                      return CupertinoButton(
                        sizeStyle: CupertinoButtonSize.small,
                        color: Colors.black.withValues(alpha: .72),
                        borderRadius: BorderRadius.circular(24),
                        onPressed: showMenu,
                        child: Row(
                          spacing: 6,
                          children: [
                            Icon(CupertinoIcons.tv),
                            Text("播放源"),
                          ],
                        ),
                      );
                    }),
                    Zoom(
                      child: CupertinoButton(
                        sizeStyle: CupertinoButtonSize.small,
                        color: Colors.black.withValues(alpha: .72),
                        borderRadius: BorderRadius.circular(24),
                        child: Row(
                          spacing: 6,
                          children: [
                            Icon(CupertinoIcons.ellipsis_circle_fill),
                            Text("频道"),
                          ],
                        ),
                        onPressed: () {
                          scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                    ),
                    Zoom(
                      child: CupertinoButton(
                        sizeStyle: CupertinoButtonSize.small,
                        color: Colors.black.withValues(alpha: .72),
                        borderRadius: BorderRadius.circular(24),
                        onPressed: () {
                          homeController.setBottomNavigationBar(
                            !homeController.showBottomNavigationBar,
                          );
                        },
                        child: Row(
                          spacing: 6,
                          children: [
                            Icon(Icons.open_in_full_rounded),
                            Text("半全屏"),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        AnimatedPositioned(
          left: 0,
          right: 0,
          bottom: showVideoControls ? 0 : -72,
          duration: const Duration(milliseconds: 210),
          child: Stack(
            children: [
              Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: .42),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.42),
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            child: Row(
                              spacing: 6,
                              children: [
                                Text("LIVE", style: TextStyle(color: Colors.white)),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    // 正常播放显示绿色, 播放失败显示红色
                                    color: state.widget.controller.player.state
                                            .playing
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 刷新
                          // IconButton(
                          //   icon: const Icon(Icons.refresh),
                          //   onPressed: () {
                          //     state.widget.controller.player.setRate(1.0);
                          //     state.widget.controller.player.setPitch(1.0);
                          //     state.widget.controller.player.setVolume(1.0);
                          //     state.widget.controller.player.setShuffle(false);
                          //     state.widget.controller.player.setPlaylistMode(
                          //       PlaylistMode.loop,
                          //     );
                          //   },
                          // ),
                        ],
                      ),
                      Row(
                        children: [
                          // 音量
                          // https://pub.dev/packages/interactive_slider
                          // IconButton(
                          //   icon: const Icon(Icons.volume_up),
                          //   onPressed: () {
                          //     state.widget.controller.player.setVolume(
                          //       state.widget.controller.player.state.volume +
                          //           5.0,
                          //     );
                          //   },
                          // ),
                          // 上一个频道
                          // IconButton(
                          //   icon: const Icon(Icons.skip_previous),
                          //   onPressed: () {
                          //     state.widget.controller.player.previous();
                          //   },
                          // ),
                          // 播放/暂停
                          // IconButton(
                          //   icon: StreamBuilder<bool>(
                          //     stream:
                          //         state.widget.controller.player.stream.playing,
                          //     builder: (context, playing) => Icon(
                          //       (playing.data ?? false)
                          //           ? Icons.pause
                          //           : Icons.play_arrow,
                          //     ),
                          //   ),
                          //   onPressed: () {
                          //     state.widget.controller.player.playOrPause();
                          //   },
                          // ),
                          // 下一个频道
                          // IconButton(
                          //   icon: const Icon(Icons.skip_next),
                          //   onPressed: () {
                          //     state.widget.controller.player.next();
                          //   },
                          // ),
                          // 视频填充模式
                          Zoom(
                            child: IconButton(
                              icon: const Icon(
                                Icons.aspect_ratio,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                List<BoxFit> fits = kVideoFits.keys.toList();
                                int idx = fits.indexOf(videoFit);
                                idx = (idx + 1) % fits.length;
                                videoFit = fits[idx];
                                setState(() {});

                                var msg =
                                    "切换到${kVideoFits[videoFit] ?? '未知模式'}";
                                EasyLoading.showToast(
                                  msg,
                                  toastPosition:
                                      EasyLoadingToastPosition.bottom,
                                );
                              },
                            ),
                          ),
                          // 全屏
                          Zoom(
                            child: IconButton(
                              icon: const Icon(Icons.fullscreen, color: Colors.white),
                              onPressed: () async {
                                if (GetPlatform.isDesktop) {
                                  bool isFullScreen =
                                      await windowManager.isFullScreen();
                                  windowManager.setFullScreen(!isFullScreen);
                                } else {
                                  var orientation =
                                      MediaQuery.of(context).orientation;
                                  if (orientation == Orientation.portrait) {
                                    await SystemChrome
                                        .setPreferredOrientations([
                                      DeviceOrientation.landscapeLeft,
                                      DeviceOrientation.landscapeRight,
                                    ]);
                                    homeController
                                        .setBottomNavigationBar(false);
                                  } else {
                                    await SystemChrome
                                        .setPreferredOrientations([
                                      DeviceOrientation.portraitUp,
                                      DeviceOrientation.portraitDown,
                                    ]);
                                    homeController.setBottomNavigationBar(true);
                                  }
                                  showVideoControls = false;
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNowLiveTV() {
    return Builder(builder: (context) {
      if (currTVIdx < 0) {
        return const SizedBox.shrink();
      }
      var tv = currTVS[currTVIdx];
      return Container(
        decoration: BoxDecoration(
            color: '#313131'.$color.withValues(alpha: .42),
            border: Border.all(
              color: kActiveColor.withValues(alpha: .72),
              // color: '#27b2ff'.$color,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: kActiveColor.withValues(alpha: .72),
                // color: '#27b2ff'.$color,
                blurRadius: 3,
                spreadRadius: 0,
                offset: Offset(0, 0),
              ),
            ]),
        clipBehavior: Clip.hardEdge,
        padding: EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 3,
        ),
        child: Row(
          spacing: 6,
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedNetworkImage(
              width: 24,
              height: 24,
              imageUrl: tv.logo ?? "",
              errorWidget: (_, __, ___) => Icon(
                Icons.live_tv,
                size: 24,
              ),
              placeholder: (_, __) => Center(
                child: CupertinoActivityIndicator(),
              ),
            ),
            Text(
              tv.name,
              style: TextStyle(
                color: '#27b2ff'.$color.withValues(alpha: .88),
              ),
            ),
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                // TODO(d1y): 动态获取播放状态, 正常为 green, 错误为 red
                color: '#03ff00'.$color,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBody() {
    bool isDesktop = context.mediaQuery.size.width >= 600;
    var bgWidget = Positioned.fill(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            image: NetworkImage(kWallpaper),
            fit: BoxFit.cover,
            opacity: .42,
          ),
        ),
      ),
    );
    return Positioned.fill(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: scaffoldKey,
        onDrawerChanged: (isOpened) {
          if (!isOpened) {
            focusNode.requestFocus();
          } else {
            if (GetPlatform.isDesktop) {
              _autoHideCursorTimer?.cancel();
              hideCursor.showCursor();
            }
          }
        },
        drawer: _buildDrawer(),
        body: Shortcuts(
          shortcuts: {
            SingleActivator(LogicalKeyboardKey.keyS, meta: true): TabToggle()
          },
          child: Actions(
            actions: {
              TabToggle: CallbackAction<TabToggle>(
                onInvoke: (_) {
                  toggleDrawer();
                  return null;
                },
              ),
            },
            child: KeyboardListener(
              focusNode: focusNode,
              autofocus: true,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                padding: EdgeInsets.only(
                  bottom: homeController.showBottomNavigationBar ? kDefaultAppBottomBarHeight : 0,
                ),
                child: Stack(
                  children: [
                    if (isDesktop) bgWidget,
                    Positioned.fill(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Stack(
                              children: [
                                if (!isDesktop) bgWidget,
                                Positioned.fill(
                                  child: Video(
                                    controller: controller,
                                    controls: _buildVideoControls,
                                    fit: videoFit,
                                    fill: Colors.black.withValues(alpha: .24),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (context.mediaQuery.size.width < 700)
                            Expanded(
                              flex: 9,
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: '#313131'.$color,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 12,
                                      ),
                                      child: Row(
                                        spacing: 12,
                                        children: [
                                          _buildLiveSourceButton(
                                              (cx, showMenu) {
                                            var name = "播放源";
                                            if (currLiveSource != null) {
                                              name = currLiveSource!.name;
                                            }
                                            return ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 142,
                                              ),
                                              child: CupertinoButton.filled(
                                                color: '#3e3e3e'.$color,
                                                sizeStyle:
                                                    CupertinoButtonSize.small,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                ),
                                                onPressed: showMenu,
                                                child: Row(
                                                  spacing: 6,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        name,
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          color: '#767579'.$color,
                                                        ),
                                                      ),
                                                    ),
                                                    Icon(
                                                      CupertinoIcons
                                                          .chevron_down,
                                                      color: '#8e8e92'.$color,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                          Zoom(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                maxWidth: 120,
                                              ),
                                              child: CupertinoButton.filled(
                                                color: '#3e3e3e'.$color,
                                                sizeStyle:
                                                    CupertinoButtonSize.medium,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Builder(builder: (context) {
                                                        var channelName =
                                                            currGroupName.isNotEmpty
                                                                ? currGroupName
                                                                : "全部频道";
                                                        if (currGroupName
                                                            .isNotEmpty) {
                                                          channelName +=
                                                              "(${currTVS.length})";
                                                        }
                                                        return Text(
                                                          channelName,
                                                          overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  '#767579'.$color),
                                                        );
                                                      }),
                                                    ),
                                                    Icon(
                                                        CupertinoIcons
                                                            .chevron_down,
                                                        color: '#8e8e92'.$color),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  toggleDrawer();
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: '#3a3a3a'.$color,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Builder(builder: (context) {
                                          var tvs = currTVS;
                                          if (tvs.isEmpty) {
                                            return Center(
                                              child: Column(
                                                spacing: 12,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    CupertinoIcons
                                                        .bubble_middle_bottom,
                                                    size: 66,
                                                    color: Colors.white,
                                                  ),
                                                  Text("请先选择频道 :)", style: TextStyle(color: Colors.white),),
                                                  SizedBox(
                                                    height: context.mediaQuery
                                                            .size.height *
                                                        .12,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          return SmoothListView.builder(
                                            duration: kSmoothListViewDuration,
                                            itemCount: tvs.length,
                                            itemBuilder: (cx, idx) {
                                              var item = tvs[idx];
                                              var isSelected = currTVIdx == idx;
                                              return Material(
                                                color: Colors.transparent,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 3),
                                                  child: ListTile(
                                                    dense: true,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    onTap: () {
                                                      currTVIdx = idx;
                                                      setState(() {});
                                                      playURL(item.url);
                                                    },
                                                    selected: isSelected,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    selectedTileColor:
                                                        kActiveColor,
                                                    hoverColor: Colors.white
                                                        .withValues(
                                                            alpha: 0.42),
                                                    leading: CachedNetworkImage(
                                                      width: 80,
                                                      height: double.infinity,
                                                      imageUrl: item.logo ?? "",
                                                      errorWidget:
                                                          (_, __, ___) => Icon(
                                                        Icons.live_tv,
                                                        size: 48,
                                                      ),
                                                      placeholder: (_, __) =>
                                                          Center(
                                                        child:
                                                            CupertinoActivityIndicator(),
                                                      ),
                                                    ),
                                                    title: Text(
                                                      item.name,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 28,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                                    subtitle: Row(
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: '#2a2a2a'
                                                                .$color,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            vertical: 3,
                                                            horizontal: 12,
                                                          ),
                                                          child: Text(
                                                            item.groupName,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBody(),
        _buildDesktopCTRL(),
      ],
    );
  }
}

class PlayPauseAnimatedIcon extends StatefulWidget {
  final bool playing;
  final double size;
  final Color? color;
  const PlayPauseAnimatedIcon({
    super.key,
    required this.playing,
    this.size = 48,
    this.color,
  });

  @override
  State<PlayPauseAnimatedIcon> createState() => _PlayPauseAnimatedIconState();
}

class _PlayPauseAnimatedIconState extends State<PlayPauseAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.playing ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant PlayPauseAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playing != oldWidget.playing) {
      if (widget.playing) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedIcon(
      icon: AnimatedIcons.play_pause,
      progress: _controller,
      size: widget.size,
      color: widget.color,
    );
  }
}
