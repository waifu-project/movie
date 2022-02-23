// Copyright (C) 2021, 2022 d1y <chenhonzhou@gmail.com>
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

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 屏幕方向
enum ScreenDirction {
  /// 横屏
  x,

  /// 竖屏
  y
}

/// 切换屏幕方向
/// [action] 操作的方向
/// [beforeTime] 在执行该操作时, 猜测若有其他异步操作, 会卡死 `Flutter Engine`
execScreenDirction(
  ScreenDirction action, [
  beforeTime = const Duration(seconds: 1),
]) {
  /// 为避免卡死, 在开发模式下不执行操作
  if (kReleaseMode) {
    Future.delayed(beforeTime, () {
      switch (action) {
        case ScreenDirction.x:
          AutoOrientation.landscapeAutoMode();
          break;
        case ScreenDirction.y:
          AutoOrientation.portraitAutoMode();
          break;
        default:
      }
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      );
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    });
  }
}
