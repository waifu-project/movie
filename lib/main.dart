import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:movie/config.dart';
import 'package:movie/mirror/mirror.dart';
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

Future<Tuple2<Brightness, bool>> runBefore() async {
  WidgetsFlutterBinding.ensureInitialized();
  await XHttp.init();
  await GetStorage.init();
  await MirrorManage.init();
  final localStorage = GetStorage();

  bool isDark = (localStorage.read(ConstDart.ls_isDark) ?? false);
  bool systemBrightnessFlag = (localStorage.read(ConstDart.auto_dark) ?? false);

  Brightness wrapperIfDark = Brightness.light;

  {
    if (isDark) wrapperIfDark = Brightness.dark;
    if (GetPlatform.isWindows && systemBrightnessFlag) {
      var windowMode = getWindowsThemeMode();
      wrapperIfDark = windowMode;
    }
  }

  // ignore: dead_code
  if (false) {
    // remove this(不记得为什么要写这一段代码了, 估计是为了兼容)
    if (GetPlatform.isMacOS && systemBrightnessFlag) {
      wrapperIfDark =
          Get.isPlatformDarkMode ? Brightness.dark : Brightness.light;
    }
  }

  return Tuple2(wrapperIfDark, systemBrightnessFlag);
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
