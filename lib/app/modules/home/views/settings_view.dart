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

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_settings/flutter_cupertino_settings.dart';

import 'package:get/get.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/modules/home/views/source_help.dart';
import 'package:movie/app/widget/window_appbar.dart';
import 'package:movie/config.dart';
import 'package:movie/mirror/m_utils/source_utils.dart';
import 'package:movie/mirror/mirror.dart';
import 'package:movie/utils/helper.dart';

import 'nsfwtable.dart';

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
  const SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final HomeController home = Get.find<HomeController>();

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/data/source_help.txt');
  }

  String sourceHelpText = "";

  bool _isDark = false;

  bool get isDark {
    return _isDark;
  }

  set isDark(bool newVal) {
    home.localStorage.write(ConstDart.ls_isDark, newVal);
    setState(() {
      _isDark = newVal;
    });
    Get.changeTheme(!newVal ? ThemeData.light() : ThemeData.dark());
  }

  bool _autoDarkMode = false;

  set autoDarkMode(bool newVal) {
    home.localStorage.write(ConstDart.auto_dark, newVal);
    setState(() {
      _autoDarkMode = newVal;
    });
    if (!newVal) {
      Get.changeTheme(!_isDark ? ThemeData.light() : ThemeData.dark());
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
      _isDark = home.localStorage.read(ConstDart.ls_isDark) ?? false;
      _autoDarkMode = home.localStorage.read(ConstDart.auto_dark) ?? false;
      _canBeShowIosBrowser = home.iosCanBeUseSystemBrowser;
    });
    loadSourceHelp();
    addMirrorMangerTextareaLister();
    super.initState();
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  addMirrorMangerTextareaLister() {
    editingControllerValue =
        home.localStorage.read<String>(ConstDart.mirror_textArea) ?? "";
    _editingController.addListener(() {
      home.localStorage.write(
        ConstDart.mirror_textArea,
        editingControllerValue,
      );
    });
  }

  loadSourceHelp() async {
    var data = await loadAsset();
    setState(() {
      sourceHelpText = data;
    });
  }

  bool get showNSFW {
    return (home.isNsfw || nShowNSFW >= 10);
  }

  set showNSFW(newVal) {
    // TODO 为 `false` 时
    // showBlurModel();

    setState(() {
      nShowNSFW = !newVal ? 0 : 10;
    });
  }

  int _nShowNSFW = 0;

  int get nShowNSFW => _nShowNSFW;

  set nShowNSFW(newVal) {
    setState(() {
      _nShowNSFW = newVal;
    });
    if (_nShowNSFW >= 10) {
      showBlurModel();
    }
  }

  showBlurModel({
    Duration time = const Duration(seconds: 2),
  }) {
    // if (Get.isDialogOpen ?? false) return;
    Get.dialog(
      Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
        ),
      ),
    );
    Future.delayed(time, () {
      Get.back();
    });
  }

  TextEditingController _editingController = TextEditingController();

  String get editingControllerValue {
    return _editingController.text.trim();
  }

  set editingControllerValue(String newVal) {
    _editingController.text = newVal;
  }

  handleDiglogTap(HandleDiglogTapType type) async {
    switch (type) {
      case HandleDiglogTapType.clean:
        editingControllerValue = "";
        Get.showSnackbar(
          GetBar(
            message: "解析内容已经清空!",
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case HandleDiglogTapType.kget:
        if (editingControllerValue.isEmpty) {
          Get.showSnackbar(
            GetBar(
              message: "内容为空, 请填入url!",
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
        var target = SourceUtils.getSources(editingControllerValue);
        Get.dialog(
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.6),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(
                      height: 42,
                    ),
                    CupertinoButton.filled(
                      child: Text("关闭"),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        var data = await SourceUtils.runTaks(target);
        Get.back();
        if (data.isEmpty) {
          Get.showSnackbar(
            GetBar(
              message: "获取的内容为空!",
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
        var listData = SourceUtils.mergeMirror(data);
        MirrorManage.mergeMirror(listData);
        Get.showSnackbar(
          GetBar(
            message: "获取成功, 已合并资源",
            duration: Duration(seconds: 1),
          ),
        );
        break;
      default:
    }
  }

  /// 是否显示`ios`默认浏览器设置
  bool canBeShowIosBrowserSettings = GetPlatform.isIOS || kDebugMode;

  bool _canBeShowIosBrowser = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WindowAppBar(
        title: Text("设置"),
        centerTitle: true,
        actions: [SizedBox.shrink()],
      ),
      body: CupertinoSettings(
        items: <Widget>[
          const CSHeader('常规设置'),
          !autoDarkMode
              ? CSControl(
                  nameWidget: Text('深色'),
                  contentWidget: CupertinoSwitch(
                    value: isDark,
                    onChanged: (bool value) {
                      isDark = value;
                    },
                  ),
                  style: const CSWidgetStyle(
                    icon: const Icon(
                      Icons.settings_brightness,
                    ),
                  ),
                )
              : SizedBox.shrink(),
          CSControl(
            nameWidget: Text('深色跟随系统'),
            contentWidget: CupertinoSwitch(
              value: autoDarkMode,
              onChanged: (bool value) {
                autoDarkMode = value;
              },
            ),
            style: const CSWidgetStyle(
              icon: const Icon(
                CupertinoIcons.moon_stars_fill,
              ),
            ),
          ),
          GestureDetector(
            child: CSControl(
              nameWidget: Text("视频源管理"),
              style: const CSWidgetStyle(
                icon: const Icon(
                  Icons.video_library,
                ),
              ),
            ),
            onTap: () {
              Get.defaultDialog(
                actions: [
                  CupertinoButton.filled(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Text("清空"),
                    onPressed: () {
                      handleDiglogTap(HandleDiglogTapType.clean);
                    },
                  ),
                  CupertinoButton.filled(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Text("获取配置"),
                    onPressed: () {
                      handleDiglogTap(HandleDiglogTapType.kget);
                    },
                  ),
                ],
                titlePadding: EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 12,
                ),
                title: "我的视频源网络地址",
                titleStyle: TextStyle(
                  fontSize: 16,
                ),
                content: Container(
                  height: Get.height * .2,
                  width: context.widthTransformer(dividedBy: 1),
                  child: Card(
                    color: Color.fromRGBO(0, 0, 0, .02),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
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
            },
          ),
          canBeShowIosBrowserSettings
              ? CSControl(
                  nameWidget: Text('iOS播放使用内置浏览器'),
                  contentWidget: CupertinoSwitch(
                    value: _canBeShowIosBrowser,
                    onChanged: (bool value) async {
                      setState(() {
                        _canBeShowIosBrowser = value;
                      });
                      home.iosCanBeUseSystemBrowser = value;
                    },
                  ),
                  style: const CSWidgetStyle(
                    icon: const Icon(
                      Icons.airplay_rounded,
                    ),
                  ),
                )
              : SizedBox.shrink(),
          showNSFW
              ? CSControl(
                  nameWidget: Text('NSFW'),
                  contentWidget: CupertinoSwitch(
                    value: home.isNsfw,
                    onChanged: (bool value) async {
                      if (value) {
                        GetBackResultType result =
                            await Get.to(() => NsfwTableView());
                        if (result == GetBackResultType.success) {
                          home.isNsfw = true;
                          showNSFW = true;
                          home.update();
                          return;
                        }
                      }
                      showNSFW = false;
                      home.isNsfw = false;
                      home.update();
                    },
                  ),
                  style: const CSWidgetStyle(
                    icon: const Icon(
                      Icons.stop_screen_share,
                    ),
                  ),
                )
              : SizedBox.shrink(),
          const CSHeader('其他设置'),
          GestureDetector(
            onTap: () {
              Get.to(() => SourceHelpTable());
            },
            child: CSControl(
              nameWidget: Text("视频源帮助"),
              style: const CSWidgetStyle(
                icon: const Icon(
                  CupertinoIcons.arrow_down_right_square_fill,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              var ctx = Get.context;
              if (ctx == null) return;
              showCupertinoDialog(
                builder: (BuildContext context) => CupertinoAlertDialog(
                  title: const Text('提示'),
                  content: Text("将删除所有缓存, 包括视频源和一些设置"),
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
                      child: const Text(
                        '确定',
                        style: TextStyle(color: Colors.blue),
                      ),
                      isDestructiveAction: true,
                      onPressed: () async {
                        await home.localStorage.erase();
                        Get.back();
                        showCupertinoDialog(
                          builder: (context) => CupertinoAlertDialog(
                            content: Text("已删除缓存, 重启之后生效!"),
                            actions: [
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
                            ],
                          ),
                          context: context,
                        );
                      },
                    )
                  ],
                ),
                context: ctx,
              );
            },
            child: CSControl(
              nameWidget: Text("清除缓存"),
              style: const CSWidgetStyle(
                icon: const Icon(
                  CupertinoIcons.clear_thick_circled,
                ),
              ),
            ),
          ),
          CSButton(
            CSButtonType.DEFAULT,
            "Licenses",
            () {
              showLicensePage(
                context: context,
                applicationIcon: Image.asset(
                  "assets/images/fishtank.png",
                  width: Get.width * .25,
                ),
              );
            },
          ),
          SizedBox(
            height: 24,
          ),
          GestureDetector(
            onTap: () {
              if (showNSFW) {
                showNSFW = false;
              } else {
                setState(() {
                  nShowNSFW++;
                });
              }
            },
            child: CSDescription(
              "@陈大大哦了",
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                LaunchURL(GITHUB_OPEN);
              },
              child: Padding(
                padding: EdgeInsets.all(12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 12,
                      ),
                      Image.asset(
                        "assets/images/github_logo.png",
                        width: 81,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        "开源地址ヾ(≧O≦)〃",
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
