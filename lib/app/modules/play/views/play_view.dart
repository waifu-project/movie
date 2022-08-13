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
import 'package:get/get.dart';
import 'package:movie/app/widget/window_appbar.dart';
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

class PlayView extends StatefulWidget {
  const PlayView({Key? key}) : super(key: key);

  @override
  State<PlayView> createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> {
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

  bool get canRenderIosStyle {
    return playlist.length >= 4;
  }

  final double offsetSize = 12;
  final coverHeightScale = .3;
  double scrollOffset = 0;
  final scrollController = ScrollController();
  bool get showTitle {
    bool show = scrollOffset >= Get.height * coverHeightScale;
    return show;
  }

  Matrix4 get _transform {
    return Matrix4.translationValues(0, showTitle ? 0 : 24, 0);
  }

  @override
  void initState() {
    super.initState();
    beforeHook();
  }

  beforeHook() {
    scrollController.addListener(() {
      var offset = scrollController.offset;
      print(offset);
      setState(() {
        scrollOffset = offset;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlayController>(
      builder: (play) => Scaffold(
        appBar: CupertinoEasyAppBar(
          child: Row(
            children: [
              CupertinoNavigationBarBackButton(),
              AnimatedContainer(
                transform: _transform,
                duration: Duration(
                  milliseconds: 120,
                ),
                curve: Curves.ease,
                child: AnimatedOpacity(
                  duration: Duration(
                    milliseconds: 120,
                  ),
                  opacity: showTitle ? 1 : 0,
                  child: Text(
                    play.movieItem.title,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: Get.height * coverHeightScale,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(play.movieItem.smallCoverImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: SizedBox.shrink()),
                      Container(
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 24,
                            sigmaY: 24,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                            child: Text(
                              play.movieItem.title,
                              style: Theme.of(context).textTheme.titleLarge,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  child: Text(play.movieItem.desc.replaceAll('\\\\n', '\n')),
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
                Divider(),
                Container(
                  width: double.infinity,
                  height: canRenderIosStyle ? 32 + 12 : null,
                  decoration: canRenderIosStyle
                      ? BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.pink,
                              width: 1,
                            ),
                          ),
                        )
                      : null,
                  padding: canRenderIosStyle
                      ? EdgeInsets.only(
                          bottom: 12,
                        )
                      : null,
                  child: Builder(builder: (_) {
                    var isNext = playlist.length <= 1 || tabviewData[1] == null;
                    if (isNext) return SizedBox.shrink();
                    if (canRenderIosStyle) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: playlist.length,
                        itemBuilder: (context, index) {
                          var isCurrentIndex = index == play.tabIndex;
                          var current = playlist[index];
                          return GestureDetector(
                            onTap: () {
                              play.changeTabIndex(index);
                            },
                            child: AnimatedContainer(
                              alignment: Alignment.center,
                              // width: Get.width * .334,
                              height: 32,
                              duration: Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCurrentIndex
                                      ? Colors.pink
                                      : (Get.isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              ),
                              margin: EdgeInsets.only(
                                right: 6,
                                left: 9,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                current.title,
                                style: TextStyle(
                                  color: isCurrentIndex
                                      ? Colors.pink
                                      : (Get.isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      );
                    }
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
                  child: Builder(builder: (context) {
                    if (playlist.isEmpty ||
                        (playlist.length == 1 && playlist[0].datas.isEmpty)) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.tornado,
                              size: 42,
                              color: CupertinoColors.systemBlue,
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Text(
                              "暂无播放链接",
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        ),
                      );
                    }
                    return Wrap(
                      children: playlist[play.tabIndex]
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
                                child: Builder(
                                  builder: (_) {
                                    // NOTE: `长度 = 1` 实际上会没有标题, 所以文字为默认
                                    var len = playlist[play.tabIndex].datas.length;
                                    var text = len <= 1 ? "默认" : e.name;
                                    return Text(text);
                                  }
                                ),
                                onPressed: () {
                                  play.handleTapPlayerButtom(e);
                                },
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
