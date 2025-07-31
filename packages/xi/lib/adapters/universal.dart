import '../interface.dart';
import 'package:flutter_js/flutter_js.dart';

class UniversalSpider extends ISpiderAdapter {
  @override
  Future<VideoDetail> getDetail(String movieId) async {
    getJavascriptRuntime();
    throw UnimplementedError();
  }

  @override
  Future<List<VideoDetail>> getHome({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<VideoDetail>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  }) async {
    throw UnimplementedError();
  }

  @override
  bool get isNsfw => false;

  @override
  SourceItemMeta get meta => SourceItemMeta(
        name: "",
        logo: "",
        desc: "",
        domain: "",
        id: "",
        status: false,
      );

  @override
  Future<List<SourceSpiderQueryCategory>> getCategory() async {
    throw UnimplementedError();
  }

  @override
  String toString() {
    return "";
  }
}
