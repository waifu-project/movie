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

import 'package:get_storage/get_storage.dart';
import 'package:movie/config.dart';
import 'package:movie/impl/movie.dart';
import 'package:movie/mirror/mlist/nfmovie.dart';
import 'package:movie/mirror/mlist/theporn.dart';

import 'm_utils/m.dart';
import 'mlist/base_models/source_data.dart';

class MirrorManage {
  static final local = GetStorage();

  MirrorManage._internal();

  /// 扩展的源
  static List<MovieImpl> extend = [];

  /// 内建支持的源
  /// 一般是需要自己去实现的源
  static List<MovieImpl> builtin = [
    NfmovieMirror(),
    ThePornMirror(),
  ];

  /// 合并之后的数据
  static List<MovieImpl> get data {
    return [...extend, ...builtin];
  }

  /// 初始化
  static init() async {
    var cacheData = local.read<List<dynamic>>(ConstDart.mirror_list) ?? [];
    var output = cacheData.map((e) => SourceJsonData.fromJson(e)).toList();
    var result = output.map((data) {
      return KBaseMirrorMovie(
        logo: data.logo ?? "",
        name: data.name ?? "",
        desc: data.desc ?? "",
        api_path: data.api!.path ?? "",
        root_url: data.api!.root ?? "",
        nsfw: data.nsfw ?? false,
      );
    }).toList();
    extend = result;
  }

  static mergeMirror(List<SourceJsonData> data) async {
    await local.write(ConstDart.mirror_list, data);
  }
}