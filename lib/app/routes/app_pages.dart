// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

import 'package:catmovie/app/modules/home/bindings/home_binding.dart';
import 'package:catmovie/app/modules/home/views/home_view.dart';
import 'package:catmovie/app/modules/play/bindings/play_binding.dart';
import 'package:catmovie/app/modules/play/views/play_view.dart';

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
      page: () => const PlayView(),
      binding: PlayBinding(),
    ),
  ];
}
