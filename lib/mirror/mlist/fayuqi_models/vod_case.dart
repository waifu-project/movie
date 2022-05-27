import 'package:movie/mirror/mlist/fayuqi_models/vod_movie.dart';

class RespPageData {
  RespPageData({
    this.total = -1,
    this.current = -1,
    this.totalPage = -1,
  });

  int total;
  int current;
  int totalPage;
}


class VodCaseRespData {
  VodCaseRespData({
    required this.pageData,
    required this.tags,
    required this.cards,
  });

  RespPageData pageData;
  List<String> tags;
  List<VodCard> cards;
}
