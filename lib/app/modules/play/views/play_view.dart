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

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:get/get.dart';
import 'package:movie/mirror/m_utils/m.dart';
import 'package:movie/mirror/mirror_serialize.dart';
import 'package:movie/utils/helper.dart';

import '../controllers/play_controller.dart';

class PlayListData {
  final String title;

  final List<MirrorSerializeVideoInfo> datas;

  PlayListData({
    required this.title,
    required this.datas,
  });
}

class PlayView extends GetView<PlayController> {
  final PlayController play = Get.find<PlayController>();

  List<PlayListData> get playlist {
    List<PlayListData> result = [];
    var v = play.movieItem.videos;
    v.forEach((element) {
      var url = element.url;
      var hasUrl = isURL(url);
      if (hasUrl) {
        var output = [element];
        result.add(PlayListData(title: element.name, datas: []));
        var urls = url.split("#");
        if (urls.length >= 2) {
          output = urls
              .map(
                (e) => MirrorSerializeVideoInfo(
                  url: e,
                  type: KBaseMirrorMovie.easyGetVideoType(e),
                ),
              )
              .toList();
        }
        result.last.datas.addAll(output);
      } else {
        var movies = url.split("#");
        var cache = PlayListData(title: element.name, datas: []);
        movies.forEach((e) {
          var subItem = e.split("\$");
          if (subItem.length <= 1) return;
          var title = subItem[0];
          var _url = subItem[1];
          // var subType = subItem[2];
          cache.datas.add(MirrorSerializeVideoInfo(
            name: title,
            url: _url,
            type: KBaseMirrorMovie.easyGetVideoType(_url),
          ));
        });
        result.add(cache);
      }
    });
    return result;
  }

  get tabviewData {
    Map<int, Widget> result = {};
    playlist.asMap().forEach((key, value) {
      result[key] = Text(value.title);
    });
    return result;
  }

  final double offsetSize = 12;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlayController>(
      builder: (play) => Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: Get.height * .3,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 6,
                      sigmaY: 6,
                    ),
                    child: Stack(
                      children: [
                        Image.network(
                          play.movieItem.smallCoverImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 15,
                              sigmaY: 15,
                            ),
                            child: Container(
                              color: Colors.white10,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: SizedBox.shrink()),
                                  Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text(
                                      play.movieItem.title,
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  child: Html(
                    data: play.movieItem.desc.replaceAll('\\\\n', '\n'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  child: Text(
                    "播放列表",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Builder(builder: (_) {
                    if (playlist.length <= 1 || tabviewData[1] == null)
                      return SizedBox.shrink();
                    return CupertinoSlidingSegmentedControl(
                      backgroundColor: Colors.black26,
                      thumbColor: Get.isDarkMode ? Colors.blue : Colors.white,
                      onValueChanged: (value) {
                        if (value == null) return;
                        play.changeTabIndex(value);
                      },
                      groupValue: play.tabIndex,
                      children: tabviewData,
                    );
                  }),
                ),
                SizedBox(
                  height: offsetSize,
                ),
                Padding(
                  padding: EdgeInsets.all(offsetSize),
                  child: Wrap(
                    children: [
                      ...playlist[play.tabIndex]
                          .datas
                          .map(
                            (e) => Container(
                              width: Get.width / 3 - offsetSize - offsetSize,
                              margin: EdgeInsets.only(
                                bottom: offsetSize,
                                left: offsetSize,
                              ),
                              child: CupertinoButton.filled(
                                padding: EdgeInsets.zero,
                                child: Text(
                                  playlist[play.tabIndex].datas.length == 1
                                      ? "默认"
                                      : e.name,
                                ),
                                onPressed: () {
                                  play.handleTapPlayerButtom(e);
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
