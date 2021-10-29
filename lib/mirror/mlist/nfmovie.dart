// Copyright (C) 2021 d1y <chenhonzhou@gmail.com>
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

import 'package:dio/dio.dart';
import 'package:movie/impl/movie.dart';
import 'package:html/parser.dart' as html;
import 'package:movie/mirror/mirror_serialize.dart';
import 'package:movie/utils/http.dart';

class NfmovieMirror extends MovieImpl {
  @override
  getDetail(String movie_id) {
    throw UnimplementedError();
  }

  @override
  Future<List<MirrorOnceItemSerialize>> getHome({
    int page = 1,
    int limit = 10,
  }) async {
    var resp = await XHttp.dio.get(
      "https://www.nfmovies.com",
      options: Options(
        headers: {
          "User-Agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:93.0) Gecko/20100101 Firefox/93.0",
        },
        responseType: ResponseType.plain,
      ),
    );
    var parse = html.parse(resp.data);
    var data = parse
        .querySelectorAll('.col-lg-6.col-md-6.col-sm-4.col-xs-3')
        .map((ele) {
      var coverImageElement = ele.querySelector(
        '.myui-vodlist__thumb.lazyload',
      );
      var attrs = coverImageElement!.attributes;
      return attrs;
    }).toList();
    return [];
  }

  @override
  get isNsfw => false;

  @override
  MovieMetaData get meta => MovieMetaData(
        name: "奈非影视",
        logo: "https://i.loli.net/2021/10/28/iIJYx3uwpVqHBTf.png",
        desc: "永久免费的福利超清影视站，没有套路，完全免费！",
      );

  @override
  Future<List<MirrorOnceItemSerialize>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  }) {
    throw UnimplementedError();
  }
}
