import 'package:get/get.dart';
import 'package:movie/mirror/mirror.dart';
import 'package:movie/mirror/mirror_serialize.dart';

class HomeController extends GetxController {
  
  var currentBarIndex = 0;

  List<MirrorCardSerialize> homedata = [];

  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    updateHomeData();
  }

  updateHomeData() async {
    isLoading = true;
    update();
    List<MirrorCardSerialize> data = await MirrorList[0].getHome();
    homedata = data;
    isLoading = false;
    update();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
  void changeCurrentBarIndex(int i) {
    currentBarIndex = i;
    update();
  }
}
