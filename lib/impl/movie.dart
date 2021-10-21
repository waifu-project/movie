import 'package:movie/mirror/mirror_serialize.dart';

abstract class MovieImpl {
  bool get isNsfw;

  Future<List<MirrorCardSerialize>> getHome();

  getSearch(String keyword);

  getDetail(String movie_id);
}
