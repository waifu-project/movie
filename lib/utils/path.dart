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

import 'dart:io';
import 'package:path_provider/path_provider.dart';

///文件路径工具类
class PathUtils {
  PathUtils._internal();

  ///获取缓存目录路径
  static Future<String> getCacheDirPath() async {
    Directory directory = await getTemporaryDirectory();
    return directory.path;
  }

  ///获取文件缓存目录路径
  static Future<String> getFilesDirPath() async {
    Directory directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  ///获取文档存储目录路径
  static Future<String> getDocumentsDirPath() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}