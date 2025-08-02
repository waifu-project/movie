import 'dart:async';

import 'package:catmovie/app/modules/home/views/auto_update.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/modules/home/views/parse_vip_manage.dart';
import 'package:catmovie/app/modules/home/views/source_help.dart';
import 'package:catmovie/app/shared/bus.dart';
import 'package:catmovie/git_info.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:catmovie/shared/manage.dart';
import 'package:catmovie/app/modules/home/views/cupertino_license.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:xi/models/mac_cms/source_data.dart';
import 'package:xi/xi.dart';

enum GetBackResultType {
  /// 失败
  fail,

  /// 成功
  success
}

enum HandleDiglogTapType {
  /// 清空
  clean,

  /// 获取配置
  kget,
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with AutomaticKeepAliveClientMixin {
  final HomeController home = Get.find<HomeController>();

  late StreamSubscription $$bus;

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/data/source_help.txt');
  }

  String sourceHelpText = "";

  bool _isDark = false;

  bool get isDark {
    return _isDark;
  }

  set isDark(bool newVal) {
    updateSetting(SettingsAllKey.themeMode, newVal ? SystemThemeMode.dark : SystemThemeMode.light);
    setState(() {
      _isDark = newVal;
    });
    Get.changeThemeMode(newVal ? ThemeMode.dark : ThemeMode.light);
  }

  bool _autoDarkMode = false;

  VideoKernel _videoKernel = VideoKernel.webview;

  set autoDarkMode(bool newVal) {
    if (newVal) {
      updateSetting(SettingsAllKey.themeMode, SystemThemeMode.system);
    }
    setState(() {
      _autoDarkMode = newVal;
    });
    if (!newVal) {
      _isDark = Get.isPlatformDarkMode;
      Get.changeThemeMode(!_isDark ? ThemeMode.light : ThemeMode.dark);
      return;
    }
    if (GetPlatform.isWindows) {
      var mode = getWindowsThemeMode();
      Get.changeTheme(ThemeData(brightness: mode));
    }
    Get.changeThemeMode(ThemeMode.system);
  }

  bool get autoDarkMode {
    return _autoDarkMode;
  }

  @override
  void initState() {
    setState(() {
      var themeMode =
          getSettingAsKeyIdent<SystemThemeMode>(SettingsAllKey.themeMode);
      _isDark = themeMode.isDark;
      _autoDarkMode = themeMode.isSytem;
      _videoKernel =
          getSettingAsKeyIdent<VideoKernel>(SettingsAllKey.videoKernel);
    });
    loadSourceHelp();
    addMirrorMangerTextareaLister();
    $$bus = $bus.on<SettingEvent>().listen((event) {
      updateNSFW(event.nsfw, onlyUpdate: true);
    });
    super.initState();
  }

  @override
  void dispose() {
    _editingController.dispose();
    $$bus.cancel();
    super.dispose();
  }

  void updateNSFW(bool flag, {bool onlyUpdate = false}) {
    home.isNsfw = flag;
    if (!onlyUpdate) {
      showNSFW = flag;
    }
    home.update();
  }

  void addMirrorMangerTextareaLister() {
    editingControllerValue =
        getSettingAsKeyIdent<String>(SettingsAllKey.mirrorTextarea);
    _editingController.addListener(() {
      updateSetting(SettingsAllKey.mirrorTextarea, editingControllerValue);
    });
  }

  Future<void> loadSourceHelp() async {
    var data = await loadAsset();
    setState(() {
      sourceHelpText = data;
    });
  }

  bool get showNSFW {
    return (home.isNsfw || nShowNSFW >= 10);
  }

  set showNSFW(bool newVal) {
    setState(() {
      nShowNSFW = !newVal ? 0 : 10;
    });
  }

  int _nShowNSFW = 0;

  int get nShowNSFW => _nShowNSFW;

  set nShowNSFW(int newVal) {
    setState(() {
      _nShowNSFW = newVal;
    });
  }

  final TextEditingController _editingController = TextEditingController();

  String get editingControllerValue {
    return _editingController.text.trim();
  }

  set editingControllerValue(String newVal) {
    _editingController.text = newVal;
  }

  Future<void> handleDiglogTap(HandleDiglogTapType type) async {
    switch (type) {
      case HandleDiglogTapType.clean:
        editingControllerValue = "";
        EasyLoading.showInfo("解析内容已经清空!");
        break;
      case HandleDiglogTapType.kget:
        if (editingControllerValue.isEmpty) {
          EasyLoading.showError("内容为空, 请填写url!");
          return;
        }
        var target = SourceUtils.getSources(editingControllerValue);
        if (target.isEmpty) {
          EasyLoading.showError("没有找到匹配的源!");
          return;
        }
        Get.dialog(
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Column(
                spacing: 42,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  CupertinoButton.filled(
                    child: const Text(
                      "关闭",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ),
          barrierColor: CupertinoColors.black.withValues(alpha: .9),
        );
        var data = await SourceUtils.runTaks(target);
        Get.back();
        if (data.isEmpty) {
          EasyLoading.showError("获取的内容为空!");
          return;
        }
        List<SourceJsonData> realSources = SourceUtils.mergeMirror(
          SpiderManage.extend,
          data,
          cover: true,
          diff: false,
        );
        SpiderManage.mergeSpider(realSources);
        var showMessage = "已同步成功(${realSources.length}个源)!";
        EasyLoading.showSuccess(showMessage);
        break;
      default:
    }
  }

  void handleCleanCache() {
    home.clearCache();
    home.confirmAlert(
      "已删除缓存, 部分内容重启之后生效!",
      showCancel: false,
      confirmText: "我知道了",
      context: context,
    );
  }

  List<PullDownMenuEntry> _buildVideoKernel() {
    void action(VideoKernel vk) {
      _videoKernel = vk;
      updateSetting(SettingsAllKey.videoKernel, vk);
      setState(() {});
    }

    var result = [VideoKernel.webview, VideoKernel.mediaKit].map((item) {
      return PullDownMenuItem.selectable(
        selected: item == _videoKernel,
        onTap: () => action(item),
        title: item.name,
      );
    }).toList();
    if (GetPlatform.isMacOS) {
      result.add(
        PullDownMenuItem.selectable(
          selected: VideoKernel.iina == _videoKernel,
          onTap: () {
            final bool isInstall = checkInstalledIINA();
            if (!isInstall) {
              EasyLoading.showError("未安装IINA, 请先安装!");
              return;
            }
            action(VideoKernel.iina);
          },
          title: VideoKernel.iina.name,
        ),
      );
    }
    return result;
  }

  void handleSourceHelp() {
    var cx = getSettingAsKeyIdent<String>(SettingsAllKey.mirrorTextarea).trim();
    if (cx.isNotEmpty && cx != editingControllerValue) {
      editingControllerValue = cx;
    }
    Get.defaultDialog(
      actions: [
        Zoom(
          child: CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: const Text("清空"),
            onPressed: () {
              handleDiglogTap(HandleDiglogTapType.clean);
            },
          ),
        ),
        Zoom(
          child: CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: const Text("获取配置"),
            onPressed: () {
              handleDiglogTap(HandleDiglogTapType.kget);
            },
          ),
        ),
      ],
      titlePadding: const EdgeInsets.symmetric(
        horizontal: 3,
        vertical: 12,
      ),
      title: "我的视频源网络地址",
      titleStyle: TextStyle(
        fontSize: 16,
        color: context.isDarkMode ? Colors.white : Colors.black,
      ),
      content: SizedBox(
        height: Get.height * .2,
        width: context.widthTransformer(dividedBy: 1),
        child: Card(
          color: const Color.fromRGBO(0, 0, 0, .02),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _editingController,
              maxLines: 10,
              decoration: InputDecoration.collapsed(
                hintText: sourceHelpText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void handleCleanCacheBefore(BuildContext ctx) {
    showCupertinoDialog(
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('提示'),
        content: const Text("将删除所有缓存, 包括视频源和一些设置"),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text(
              '我想想',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onPressed: () {
              Get.back();
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Get.back();
              handleCleanCache();
            },
            child: const Text(
              '确定',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      context: ctx,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: const WindowAppBar(
        title: Text("设置"),
        centerTitle: true,
        actions: [SizedBox.shrink()],
      ),
      body: SettingsList(
        applicationType: ApplicationType.cupertino,
        sections: [
          SettingsSection(
            title: Text('常规设置'),
            tiles: <SettingsTile>[
              if (!autoDarkMode)
                SettingsTile.switchTile(
                  onToggle: (value) {
                    isDark = value;
                  },
                  initialValue: isDark,
                  leading: Icon(Icons.settings_brightness),
                  title: Text('深色'),
                ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  autoDarkMode = value;
                },
                initialValue: autoDarkMode,
                leading: Icon(CupertinoIcons.moon_stars_fill),
                title: Text('深色跟随系统'),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.add_box),
                title: Text('解析线路管理'),
                onPressed: (cx) {
                  Get.to(() => const ParseVipManagePageView());
                },
                // TODO(d1y): impl this
                // value: Text("1个线路"),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.video_library),
                title: Text('视频源管理'),
                onPressed: (cx) {
                  handleSourceHelp();
                },
                // TODO(d1y): impl this
                // value: Text("55个源"),
              ),
              SettingsTile(
                leading: Icon(CupertinoIcons.macwindow),
                title: Text("播放器内核"),
                trailing: PullDownButton(
                  itemBuilder: (cx) {
                    return _buildVideoKernel();
                  },
                  buttonBuilder: (cx, showMenu) {
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: showMenu,
                      child: Text(_videoKernel.name),
                    );
                  },
                ),
              ),
              SettingsTile.switchTile(
                onToggle: updateNSFW,
                initialValue: home.isNsfw,
                leading: Icon(CupertinoIcons.hammer_fill),
                title: Text('成人模式'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('其他设置'),
            tiles: <AbstractSettingsTile>[
              SettingsTile.navigation(
                leading: Icon(CupertinoIcons.refresh_circled_solid),
                title: Text('应用更新'),
                onPressed: (cx) {
                  showCupertinoModalBottomSheet(
                    context: cx,
                    builder: (_) => AutoUpdate(),
                  );
                },
              ),
              SettingsTile.navigation(
                leading: Icon(CupertinoIcons.arrow_down_right_square_fill),
                title: Text('视频源帮助'),
                onPressed: (cx) {
                  Get.to(() => const SourceHelpTable());
                },
              ),
              SettingsTile.navigation(
                leading: Icon(CupertinoIcons.clear_thick_circled),
                title: Text('清除缓存'),
                onPressed: handleCleanCacheBefore,
              ),
              SettingsTile.navigation(
                leading: Icon(CupertinoIcons.lab_flask_solid),
                title: Text('开源协议'),
                onPressed: (cx) {
                  showCupertinoModalBottomSheet(
                    context: cx,
                    builder: (_) => SizedBox(
                      width: double.infinity,
                      height: Get.height * .72,
                      child: cupertinoLicensePage,
                    ),
                  );
                },
              ),
              Copyright(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Copyright extends AbstractSettingsTile {
  const Copyright({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: GestureDetector(
        onTap: () {
          "$kGithubRepo/tree/$gitCommit".openURL();
        },
        child: Builder(builder: (context) {
          var firstWriteYear = '2020';
          String currentYearString = DateTime.now().year.toString();
          var text = "© 小猫影视 ";
          text += "$firstWriteYear-$currentYearString ";
          text += "$gitTag($gitCommit)";
          return HoverCursor(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text,
                // textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: (Get.isDarkMode ? Colors.white : Colors.black).withValues(alpha: .42),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
