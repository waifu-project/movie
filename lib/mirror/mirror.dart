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
import 'package:movie/mirror/mlist/fayuqi.dart';
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
    FayuQiMirror(),
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
        id: data.id ?? "",
        status: data.status ?? true,
      );
    }).toList();
    extend = result;
  }

  /// 删除单个源
  static removeItem(MovieImpl item) {
    print("删除该源: $item");
    extend.remove(item);
    saveToCache(extend);
  }

  /// 删除所有源
  static cleanAll({
    bool saveToCahe = false,
  }) {
    extend = [];
    if (saveToCahe) {
      mergeMirror([]);
    }
  }

  /// 保存缓存
  /// [该方法只可用来保存第三方源]
  /// 只适用于 [KBaseMirrorMovie]
  static saveToCache(List<MovieImpl> saves) {
    List<SourceJsonData> _to = saves
        .map(
          (e) => SourceJsonData(
            name: e.meta.name,
            logo: e.meta.logo,
            desc: e.meta.desc,
            nsfw: e.isNsfw,
            api: Api(
              root: e.meta.domain,
              path: (e as KBaseMirrorMovie).api_path,
            ),
            id: e.id,
            status: e.status,
          ),
        )
        .toList();
    mergeMirror(_to);
  }

  static Future<void> mergeMirror(List<SourceJsonData> data) async {
    await local.write(ConstDart.mirror_list, data);
  }
}
