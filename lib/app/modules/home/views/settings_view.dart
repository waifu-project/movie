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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_settings/flutter_cupertino_settings.dart';

import 'package:get/get.dart';

CSWidgetStyle brightnessStyle = const CSWidgetStyle(
  icon: const Icon(Icons.brightness_medium, color: Colors.black54),
);

// https://pub.flutter-io.cn/packages/flutter_cupertino_settings

class SettingsView extends GetView {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoSettings(items: <Widget>[
        const CSHeader('常规设置'),
        CSControl(
          nameWidget: Text('深色'),
          contentWidget: CupertinoSwitch(
            value: false,
            onChanged: (bool value) {},
          ),
          style: brightnessStyle,
        ),
        CSControl(
          nameWidget: Text('NSFW'),
          contentWidget: CupertinoSwitch(
            value: false,
            onChanged: (bool value) {},
          ),
          style: brightnessStyle,
        ),
        CSDescription(
          "@陈大大哦了",
        ),
      ]),
    );
  }
}
