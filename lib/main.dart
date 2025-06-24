import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:movie/isar/repo.dart';
import 'package:movie/shared/auto_injector.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xi/utils/helper.dart';
import 'package:xi/utils/http.dart';
import 'shared/manage.dart';
import 'package:movie/shared/enum.dart';

import 'app/routes/app_pages.dart';

const kStandWenKaiFontName = "LXGW WenKai";

ThemeData applyTheme({isDark = true}) {
  var theme = isDark ? ThemeData.dark() : ThemeData.light();
  if (GetPlatform.isLinux || kDebugMode) {
    theme = theme.copyWith(
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          fontFamily: GetPlatform.isMacOS ? kStandWenKaiFontName : 'LXG',
        ),
      ),
    );
  }
  return theme;
}

/// 返回当前主题 -> [ThemeMode]
Future<ThemeMode> runBefore() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Register a custom protocol
  // For macOS platform needs to declare the scheme in ios/Runner/Info.plist
  await protocolHandler.register('yoyo');
  if (GetPlatform.isDesktop) await windowManager.ensureInitialized();

  await XHttp.init();
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
