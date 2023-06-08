import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:movie/config.dart';
import 'package:movie/isar/repo.dart';
import 'package:movie/mirror/mirror.dart';
import 'package:movie/shared/enum.dart';
import 'package:movie/utils/helper.dart';
import 'package:tuple/tuple.dart';

import 'app/routes/app_pages.dart';
import 'utils/http.dart';

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

/// 返回两个值
///
/// `Future<Tuple2<Brightness, bool>>`
///
/// 主题 | 是否是系统主题
///
/// @d1y: 只返回 `ThemeMode`
Future<Tuple2<Brightness, bool>> runBefore() async {
  WidgetsFlutterBinding.ensureInitialized();
  await XHttp.init();
  await IsarRepository().init();
  await MirrorManage.init();
  var currTheme = IsarRepository().settingsSingleModel.themeMode;
  Brightness wrapperIfDark = Brightness.light;
  if (currTheme.isDark) {
    wrapperIfDark = Brightness.dark;
  }
  if (GetPlatform.isWindows && currTheme.isSytem) {
    wrapperIfDark = getWindowsThemeMode();
  }
  return Tuple2(wrapperIfDark, currTheme.isSytem);
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
  Tuple2<Brightness, bool> futureStatus = await runBefore();
  Brightness wrapperIfDark = futureStatus.item1;
  bool systemBrightnessFlag = futureStatus.item2;

  ThemeMode currentThemeMode = systemBrightnessFlag
      ? ThemeMode.system
      : wrapperIfDark == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;

  runApp(
    GetMaterialApp(
      title: APP_TITLE,
      scrollBehavior: MyCustomScrollBehavior(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      themeMode: currentThemeMode,
      theme: applyTheme(isDark: false),
      darkTheme: applyTheme(),
    ),
  );

  runAfter();
}
