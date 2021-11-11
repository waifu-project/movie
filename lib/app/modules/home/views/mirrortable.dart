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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/widget/helper.dart';
import 'package:movie/impl/movie.dart';

class MirrorTableView extends StatefulWidget {
  const MirrorTableView({Key? key}) : super(key: key);

  @override
  _MirrorTableViewState createState() => _MirrorTableViewState();
}

class _MirrorTableViewState extends State<MirrorTableView> {
  final HomeController home = Get.find<HomeController>();

  List<MovieImpl> get mirrorList {
    return home.mirrorList;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Get.isDarkMode ? Colors.black12 : Colors.white,
        leading: GetPlatform.isDesktop ? CupertinoNavigationBarBackButton() : Container(),
        middle: Text(
          '视频源',
          style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      child: SafeArea(
        child: CupertinoScrollbar(
          child: ListView(
            children: mirrorList
                .map(
                  (e) => CupertinoListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    pressColor: Colors.pink,
                    focusColor: Colors.red,
                    selected: home.currentMirrorItem == e,
                    onTap: () {
                      var index = mirrorList.indexOf(e);
                      home.updateMirrorIndex(index);
                      Get.back();
                    },
                    title: Text(
                      e.meta.name,
                      style: TextStyle(
                        color: home.currentMirrorItem == e ? Colors.blue : e.isNsfw
                            ? Colors.red
                            : (Get.isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
                    subtitle: Text(
                      e.meta.desc,
                      style: TextStyle(
                        color: home.currentMirrorItem == e ? Colors.blue : Get.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    border: Border(
                      bottom:  BorderSide(
                        color: (home.currentMirrorItem == e || mirrorList[(home.mirrorIndex - 1 <= 1 ? 0 : (home.mirrorIndex - 1))] == e) ? Colors.blue : Get.isDarkMode ? Colors.white10 : Colors.black12,
                        width: 3.0,
                      ),
                    ),
                    trailing: Icon(CupertinoIcons.right_chevron),
                    leading: Builder(builder: (_) {
                      if (e.meta.logo.isEmpty) {
                        return Image.asset(
                          "assets/images/fishtank.png",
                          width: 80,
                        );
                      }
                      return CachedNetworkImage(
                        width: 80,
                        imageUrl: e.meta.logo,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error,) => KCoverImage,
                      );
                    }),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
