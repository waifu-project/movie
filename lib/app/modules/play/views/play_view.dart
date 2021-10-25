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

import 'package:get/get.dart';
import 'package:movie/app/modules/play/views/chewie_view.dart';
import 'package:movie/app/modules/play/views/webview_view.dart';
import 'package:movie/mirror/mirror_serialize.dart';

import '../controllers/play_controller.dart';

class PlayView extends GetView<PlayController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlayController>(
      builder: (play) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: CupertinoNavigationBarBackButton(),
          trailing: CupertinoButton(
            onPressed: () {},
            child: Icon(CupertinoIcons.share),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 2.7,
                  child: Image.network(
                    play.movieItem.smallCoverImage,
                    fit: BoxFit.fitHeight,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null)
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: child,
                        );
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(Icons.error),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  child: Text(
                    play.movieItem.title,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  child: Text(
                    play.movieItem.desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
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
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                Wrap(
                  children: [
                    ...play.movieItem.videos
                        .map(
                          (e) => Container(
                            width: Get.width / 3, // 播放三等分
                            child: CupertinoButton(
                              child: Text(
                                e.name,
                              ),
                              onPressed: () {
                                // TODO
                                if (e.type == MirrorSerializeVideoType.iframe) {
                                  Get.to(
                                    () => WebviewView(),
                                    arguments: e.url,
                                  );
                                } else if (e.type ==
                                    MirrorSerializeVideoType.m3u8) {
                                  Get.to(
                                    () => ChewieView(),
                                    arguments: {
                                      'url': e.url,
                                      'cover': play.movieItem.smallCoverImage,
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
