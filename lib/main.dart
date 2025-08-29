import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:catmovie/shared/env.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:catmovie/isar/repo.dart';
import 'package:catmovie/shared/auto_injector.dart';
import 'package:hide_cursor/hide_cursor.dart';
import 'package:media_kit/media_kit.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xi/xi.dart';
import 'shared/manage.dart';
import 'package:catmovie/shared/enum.dart';

import 'app/routes/app_pages.dart';

ThemeData applyTheme({bool isDark = true}) {
  var theme = isDark ? ThemeData.dark() : ThemeData.light();
  // TODO(d1y): support linux fallback font(s)
  // https://github.com/LastMonopoly/chinese_font_library/issues/11
  // NOTE(d1y): Linux 下最好指定一个字体(OPPO Sans 字体就不错)
  // > https://www.coloros.com/article/A00000074
  // https://github.com/wordshub/free-font
  theme = theme.copyWith(
    textTheme: TextTheme().useSystemChineseFont(
      isDark ? Brightness.dark : Brightness.light,
    ),
  );
  return theme;
}

/// 返回当前主题 -> [ThemeMode]
Future<ThemeMode> runBefore() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Make sure to add the required packages to pubspec.yaml:
  // * https://github.com/media-kit/media-kit#installation
  // * https://pub.dev/packages/media_kit#installation
  MediaKit.ensureInitialized();

  // Register a custom protocol
  // For macOS platform needs to declare the scheme in ios/Runner/Info.plist
  await protocolHandler.register('yoyo');

  if (GetPlatform.isDesktop) {
    await windowManager.ensureInitialized();
    windowManager.setTitle("小猫影视");
  }

  var enableHttpLog = CMEnv.isDebug && CMEnv.enableFullHttpLog;
  await XHttp.init(enableLog: enableHttpLog);
  await IsarRepository().init();
  await SpiderManage.init();
  registerAutoInjector();
  var currTheme = IsarRepository().settingsSingleModel.themeMode;
  Brightness wrapperIfDark = Brightness.light;
  if (currTheme.isDark) {
    wrapperIfDark = Brightness.dark;
  }
  if (GetPlatform.isWindows && currTheme.isSytem) {
    wrapperIfDark = getWindowsThemeMode();
  }
  if (currTheme.isSytem) return ThemeMode.system;
  return wrapperIfDark == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
}

void runAfter() {
  if (GetPlatform.isDesktop) {
    hideCursor.showCursor();
    doWhenWindowReady(() {
      const minSize = Size(420, 420);
      appWindow.minSize = minSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

void main() async {
  ThemeMode currentThemeMode = await runBefore();
  runApp(
    GetMaterialApp(
      title: "小猫影视",
      scrollBehavior: DragonScrollBehavior(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      themeMode: currentThemeMode,
      theme: applyTheme(isDark: false),
      darkTheme: applyTheme(),
      builder: EasyLoading.init(),
    ),
  );
  runAfter();
}
