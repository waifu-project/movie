import 'package:get/get.dart';

import 'package:movie/app/modules/home/bindings/home_binding.dart';
import 'package:movie/app/modules/home/views/home_view.dart';
import 'package:movie/app/modules/play/bindings/play_binding.dart';
import 'package:movie/app/modules/play/views/play_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PLAY,
      page: () => PlayView(),
      binding: PlayBinding(),
    ),
  ];
}
