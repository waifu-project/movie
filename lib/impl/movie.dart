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

import 'package:movie/mirror/mirror_serialize.dart';

class MovieMetaData {
  /// 图标, 默认为空将使用本地资源图标
  String logo;

  /// 资源名称
  String name;

  /// 开发者
  String developer;

  /// 开发者邮箱
  /// 用于联系维护者
  String developerMail;

  /// 介绍
  String desc;

  MovieMetaData({
    this.logo = "",
    this.developer = "",
    this.developerMail = "",
    this.desc = "",
    required this.name,
  });
}

abstract class MovieImpl {
  /// 是否为R18资源
  /// **Not Safe For Work**
  bool get isNsfw;

  /// 源信息
  MovieMetaData get meta;

  /// 获取首页
  Future<List<MirrorOnceItemSerialize>> getHome({
    int page = 1,
    int limit = 10,
  });

  /// 搜索
  /// TODO
  Future<List<MirrorOnceItemSerialize>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  });

  /// 获取视频详情
  Future<MirrorOnceItemSerialize> getDetail(String movie_id);
}
