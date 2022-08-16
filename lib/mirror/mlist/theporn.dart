// Copyright (C) 2021-2022 d1y <chenhonzhou@gmail.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'package:movie/impl/movie.dart';
import 'package:movie/utils/http.dart';

import '../mirror_serialize.dart';
import 'theporn_models/theporn_av_json_data.dart';

class ThePornMirror extends MovieImpl {

  String root_url = "https://api.theporn.xyz";

  createURL({suffix = "/v1/video/list"}) {
    return root_url + suffix;
  }

  @override
  getDetail(String movie_id) {
    throw UnimplementedError();
  }

  @override
  Future<List<MirrorOnceItemSerialize>> getHome({
    page = 1,
    limit = 10,
  }) async {
    var resp = await XHttp.dio.get(
      createURL(),
      queryParameters: {
        "start": page * limit,
        "limit": limit,
      },
    );
    var theporn = ThepornAvJsonData.fromJson(resp.data);
    var avdatas = theporn.data?.avdatas ?? [];
    if (avdatas.isEmpty) return [];
    List<MirrorOnceItemSerialize> cards = avdatas.map((avdata) {
      var desc = "";
      if (avdata.actress != null) {
        avdata.actress!.map((e) {
          if (e is String) {
            desc += ', $e';
          }
        }).toList();
      }
      if (avdata.categories != null) {
        avdata.categories!.map((e) {
          if (e is String) {
            desc += ' | $e';
          }
        }).toList();
      }
      return MirrorOnceItemSerialize(
        id: avdata.tid.toString(),
        smallCoverImage: avdata.smallCoverImageUrl ?? "",
        bigCoverImage: avdata.bigCoverImageUrl ?? "",
        title: avdata.title ?? "",
        desc: desc,
        videos: [
          MirrorSerializeVideoInfo(
            url: avdata.embedIframeUrl ?? "",
            type: MirrorSerializeVideoType.iframe,
            name: '官方源',
          ),
        ],
      );
    }).toList();
    return cards;
  }

  @override
  Future<List<MirrorOnceItemSerialize>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  }) async {
    var resp = await XHttp.dio.get(
      createURL(
        suffix: "/v1/search",
      ),
      queryParameters: {
        "keyword": keyword,
        "start": page * limit,
        "limit": limit,
      },
    );
    var theporn = ThepornAvJsonData.fromJson(resp.data);
    var avdatas = theporn.data?.avdatas ?? [];
    if (avdatas.isEmpty) return [];
    List<MirrorOnceItemSerialize> cards = avdatas.map((avdata) {
      var desc = "";
      if (avdata.actress != null) {
        avdata.actress!.map((e) {
          if (e is String) {
            desc += ', $e';
          }
        }).toList();
      }
      if (avdata.categories != null) {
        avdata.categories!.map((e) {
          if (e is String) {
            desc += ' | $e';
          }
        }).toList();
      }
      return MirrorOnceItemSerialize(
        id: avdata.tid.toString(),
        smallCoverImage: avdata.smallCoverImageUrl ?? "",
        bigCoverImage: avdata.bigCoverImageUrl ?? "",
        title: avdata.title ?? "",
        desc: desc,
        videos: [
          MirrorSerializeVideoInfo(
            url: avdata.embedIframeUrl ?? "",
            type: MirrorSerializeVideoType.iframe,
            name: '官方源',
          ),
        ],
      );
    }).toList();
    return cards;
  }

  @override
  bool get isNsfw => true;

  @override
  MovieMetaData get meta => MovieMetaData(
        name: "ThePorn",
        logo: "https://theporn22.xyz/static/logo-tp.png",
        desc: "免费成人高清在线视频,日本AV,国产AV,欧美AV",
        domain: root_url,
        id: 'theporn',
        status: true,
      );
}
