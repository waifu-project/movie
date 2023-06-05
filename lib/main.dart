import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:movie/config.dart';
import 'package:movie/mirror/mirror.dart';
import 'package:movie/utils/helper.dart';

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

/// 运行之前
Future<List<dynamic>> runBefore() async {
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

  // {
  //   if (GetPlatform.isMacOS && systemBrightnessFlag) {
  //     wrapperIfDark = Get.isPlatformDarkMode ? Brightness.dark : Brightness.light;
  //   }
  // }

  return [wrapperIfDark, systemBrightnessFlag];
}

/// 运行之后
void runAfter() {
  if (GetPlatform.isDesktop) {
    doWhenWindowReady(() {
      const minSize = Size(420, 420);
      appWindow.minSize = minSize;
      // final initialSize = Size(990, 720);
      // appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

void main() async {
  List<dynamic> _futureStatus = await runBefore();
  Brightness wrapperIfDark = _futureStatus[0];
  bool systemBrightnessFlag = _futureStatus[1];

  runApp(
    GetMaterialApp(
      title: APP_TITLE,
      scrollBehavior: MyCustomScrollBehavior(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      themeMode: systemBrightnessFlag
          ? ThemeMode.system
          : wrapperIfDark == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
      theme: applyTheme(isDark: false),
      darkTheme: applyTheme(),
    ),
  );

  runAfter();
}
