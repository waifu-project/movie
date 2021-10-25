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
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/modules/home/views/home_config.dart';
import 'package:movie/app/routes/app_pages.dart';
import 'package:movie/app/widget/movie_card_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IndexHomeView extends GetView {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeview) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "YY播放器",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                homeview.showMirrorModel(context);
              },
              icon: Icon(
                Icons.movie,
              ),
            )
          ],
        ),
        body: SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          header: WaterDropHeader(),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus? mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = Text("pull up load");
              } else if (mode == LoadStatus.loading) {
                body = CupertinoActivityIndicator();
              } else if (mode == LoadStatus.failed) {
                body = Text("Load Failed!Click retry!");
              } else if (mode == LoadStatus.canLoading) {
                body = Text("release to load more");
              } else {
                body = Text("No more Data");
              }
              return Column(
                children: [
                  body,
                  kBarHeightWidget,
                ],
              );
            },
          ),
          controller: homeview.refreshController,
          onLoading: homeview.refreshOnLoading,
          child: Builder(
            builder: (_) {
              if (homeview.isLoading) {
                return Center(child: CupertinoActivityIndicator());
              }
              return SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      controller: new ScrollController(
                        keepScrollOffset: false,
                      ),
                      crossAxisCount: 3,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 12,
                      childAspectRatio:
                          (MediaQuery.of(context).size.width / 3) /
                              (MediaQuery.of(context).size.height /
                                  4),
                      padding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      children: [
                        ...homeview.homedata
                            .map(
                              (subItem) => MovieCardItem(
                                imageUrl: subItem.smallCoverImage,
                                title: subItem.title,
                                onTap: () {
                                  Get.toNamed(
                                    Routes.PLAY,
                                    arguments: subItem,
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ],
                    ),
                    kBarHeightWidget,
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
