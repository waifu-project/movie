import 'package:get/get.dart';

import '../controllers/play_controller.dart';

class PlayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlayController>(
      () => PlayController(),
    );
  }
}
