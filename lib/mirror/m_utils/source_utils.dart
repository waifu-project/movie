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
import 'package:movie/mirror/mirror.dart';
import 'package:movie/mirror/mlist/base_models/source_data.dart';
import 'package:movie/utils/helper.dart';
import 'package:movie/utils/http.dart';

import 'm.dart';

class SourceUtils {
  /// [rawString] 从输入框拿到值
  /// 1. 去除`\n`行
  /// 2. 如果不是 `url` 也不需要
  static List<String> getSources(String rawString) {
    var spList = rawString.split("\n");
    return spList.map((e) => e.trim()).toList().where((item) {
      var flag = (!item.isEmpty && isURL(item));
      return flag;
    }).toList();
  }

  /// TODO
  /// [url] 需要测试的链接
  /// 支持类型
  ///   github.com/d1y/1/2.json
  ///   d1y/repo/1/2.json
  static bool isGithubUrl(String url) {
    return false;
  }

  /// TODO
  /// 通过 [isGithubUrl] 判断
  /// 如果是 `github` 链接的话就通过这个方法
  /// 生成一个 `jsdelivr` cdn 链接用于下载
  static String shortToGithubCDNURL() {
    return "";
  }

  /// 加载网络源
  static Future<List<KBaseMirrorMovie>> runTaks(List<String> sources) async {
    List<KBaseMirrorMovie> result = [];
    await Future.forEach(sources, (String element) async {
      try {
        var resp = await XHttp.dio.get(
          element,
          options: Options(
            responseType: ResponseType.json, // 暂未设计出 `.xv` 文件, 通过 `json` 导入
            receiveTimeout: 1000,
            sendTimeout: 1000,
          ),
        );
        List<dynamic> _data = resp.data;
        _data.map((ele) {
          SourceJsonData data = SourceJsonData.fromJson(ele);
          var rootUrl = data.api!.root ?? "";
          result.removeWhere((item) => item.root_url == rootUrl);
          var obj = KBaseMirrorMovie(
            logo: data.logo ?? "",
            name: data.name ?? "",
            desc: data.desc ?? "",
            api_path: data.api!.path ?? "",
            root_url: data.api!.root ?? "",
            nsfw: data.nsfw ?? false,
          );
          result.add(obj);
        }).toList();
      } catch (e) {
        print("获取网络源失败: $e");
        return null;
      }
    });
    return result;
  }

  /// [runTaks] 获取到网络资源之后
  /// 和 [MirrorList] 合并
  static List<SourceJsonData> mergeMirror(List<KBaseMirrorMovie> newSourceData) {
    newSourceData.forEach((element) {
      var newDataDomain = element.meta.domain;
      MirrorManage.extend
          .removeWhere((element) => element.meta.domain == newDataDomain);
    });

    MirrorManage.extend.addAll(newSourceData);

    var copyData = (MirrorManage.extend as List<KBaseMirrorMovie>)
        .map(
          (e) => SourceJsonData(
            name: e.meta.name,
            logo: e.meta.logo,
            desc: e.meta.desc,
            nsfw: e.isNsfw,
            api: Api(
              root: e.meta.domain,
              path: e.api_path,
            ),
          ),
        )
        .toList();
    return copyData;
  }
}
