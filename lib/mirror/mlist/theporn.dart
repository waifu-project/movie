import 'package:dio/dio.dart';
import 'package:movie/impl/movie.dart';

import '../mirror_serialize.dart';
import 'theporn_models/theporn_av_json_data.dart';

class ThePornMirror extends MovieImpl {
  Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api.theporn.xyz',
  ));

  @override
  getDetail(String movie_id) {
    // TODO: implement getDetail
    throw UnimplementedError();
  }

  @override
  Future<List<MirrorCardSerialize>> getHome({ page=0, limit=0 }) async {
    var resp = await dio.get("/v1/video/list");
    var theporn = ThepornAvJsonData.fromJson(resp.data);
    var avdatas = theporn.data?.avdatas ?? [];
    if (avdatas.isEmpty) return [];
    List<MirrorOnceItemSerialize> cards = avdatas.map((avdata) {
      return MirrorOnceItemSerialize(
        id: avdata.tid.toString(),
        smallCoverImage: avdata.smallCoverImageUrl,
        title: avdata.title,
        videoType: MirrorSerializeVideoType.iframe,
        videoUrl: avdata.embedIframeUrl,
      );
    }).toList();
    return [MirrorCardSerialize(cards: cards)];
  }

  @override
  getSearch(String keyword) {
    // TODO: implement getSearch
    throw UnimplementedError();
  }

  @override
  bool get isNsfw => true;
}
