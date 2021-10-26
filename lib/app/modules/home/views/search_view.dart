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

import 'package:flappy_search_bar_ns/flappy_search_bar_ns.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/routes/app_pages.dart';
import 'package:movie/mirror/mirror_serialize.dart';

class SearchView extends GetView {
  final HomeController home = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SearchBar<MirrorOnceItemSerialize>(
          onItemFound: (item, int index) {
            return GestureDetector(
              onTap: () async {
                var data = item;
                if (item!.videos.isEmpty) {
                  String? id = item.id;
                  if (id != null) {
                    data = await home.currentMirrorItem.getDetail(id);
                  }
                }
                Get.toNamed(
                  Routes.PLAY,
                  arguments: data,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1.2,
                      color: Colors.black12,
                    ),
                  ),
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 6,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        6,
                      ),
                      child: Image.network(
                        item?.smallCoverImage ??
                            home.currentMirrorItem.meta.logo,
                        width: 80,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item?.title ?? "",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          minimumChars: 2,
          debounceDuration: Duration(
            seconds: 2,
          ),
          onSearch: (String? text) async {
            if (text == null) return [];
            return await home.updateSearchData(text);
          },
          emptyWidget: Center(
            child: Text("搜索内容为空"),
          ),
          onError: (error) {
            return Center(
              child: Text(error.toString()),
            );
          },
          cancellationWidget: Text("取消"),
          searchBarPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ),
        ),
      ),
    );
  }
}
