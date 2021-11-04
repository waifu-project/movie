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

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/config.dart';
import 'package:movie/mirror/mirror_serialize.dart';

class PlayController extends GetxController {
  MirrorOnceItemSerialize movieItem = Get.arguments;

  HomeController home = Get.find<HomeController>();

  bool _canShowPlayTips = false;

  int tabIndex = 0;

  changeTabIndex(dynamic i) {
    tabIndex = i;
    update();
  }

  bool get canShowPlayTips {
    return _canShowPlayTips;
  }

  set canShowPlayTips(bool newVal) {
    _canShowPlayTips = newVal;
    update();
    home.localStorage.write(ConstDart.showPlayTips, newVal);
  }

  String playTips = "";

  loadAsset() async {
    var tips = await rootBundle.loadString('assets/data/play_tips.txt');
    playTips = tips;
    update();
  }

  showPlayTips() {
    var ctx = Get.context;
    if (ctx == null) return;
    showCupertinoDialog(
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('免责提示'),
        content: Text(playTips),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text(
              '不在提醒',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onPressed: () {
              canShowPlayTips = false;
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text(
              '我知道了',
              style: TextStyle(color: Colors.blue),
            ),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      context: ctx,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _canShowPlayTips =
        home.localStorage.read<bool>(ConstDart.showPlayTips) ?? true;
    update();
    if (canShowPlayTips) {
      Timer(Duration(seconds: 2), () {
        showPlayTips();
      });
    }
  }

  @override
  void onReady() {
    super.onReady();
    loadAsset();
  }

  @override
  void onClose() {}
}
