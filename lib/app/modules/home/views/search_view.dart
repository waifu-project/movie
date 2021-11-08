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
import 'package:flappy_search_bar_ns/search_bar_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/routes/app_pages.dart';
import 'package:movie/app/widget/helper.dart';
import 'package:movie/app/widget/k_tag.dart';
import 'package:movie/app/widget/window_appbar.dart';
import 'package:movie/mirror/mirror_serialize.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final HomeController home = Get.find<HomeController>();

  final SearchBarController _searchBarController =
      SearchBarController<MirrorOnceItemSerialize>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GetPlatform.isDesktop ? WindowAppBar(
        title: SizedBox.shrink(),
      ) : null,
      body: SafeArea(
        child: SearchBar<MirrorOnceItemSerialize>(
          textStyle: TextStyle(
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
          searchBarController: _searchBarController,
          onItemFound: (item, int index) {
            return GestureDetector(
              onTap: () async {
                var data = item;
                if (item!.videos.isEmpty) {
                  String id = item.id;
                  Get.dialog(
                    Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  );
                  data = await home.currentMirrorItem.getDetail(id);
                  Get.back();
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
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 6,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      item?.smallCoverImage ?? home.currentMirrorItem.meta.logo,
                      width: 80,
                      height: 160,
                      fit: BoxFit.cover,
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
                      errorBuilder: (context, error, stackTrace) => ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          K_DEFAULT_IMAGE,
                          fit: BoxFit.cover,
                          width: 80,
                        ),
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
          searchBarStyle: SearchBarStyle(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(24.0),
            ),
          ),
          minimumChars: 2,
          debounceDuration: Duration(
            seconds: 2,
          ),
          onSearch: handleSearch,
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
          placeHolder: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 1,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        children: [
                          Positioned(
                            left: 12,
                            bottom: -6,
                            child: Container(
                              width: 120,
                              height: 12,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            "搜索历史",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                      IconButton(
                        tooltip: "删除所有历史记录",
                        padding: EdgeInsets.symmetric(
                          vertical: 3,
                          horizontal: 2,
                        ),
                        onPressed: () {
                          home.handleUpdateSearchHistory(
                            "",
                            type: UpdateSearchHistoryType.clean,
                          );
                        },
                        icon: Icon(CupertinoIcons.clear),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  home.searchHistory.isEmpty
                      ? Text(
                          "暂无历史记录",
                          style: Theme.of(context).textTheme.subtitle2,
                        )
                      : Wrap(
                          children: home.searchHistory
                              .map(
                                (e) => KTag(
                                  child: Text(e),
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black26
                                          : Colors.black12,
                                  onTap: (type) {
                                    switch (type) {
                                      case KTagTapEventType.content: // 内容
                                        home.handleUpdateSearchHistory(
                                          e,
                                          type: UpdateSearchHistoryType.add,
                                        );
                                        _searchBarController.injectSearch(
                                          e,
                                          handleSearch,
                                        );
                                        break;
                                      case KTagTapEventType.action: // action
                                        home.handleUpdateSearchHistory(
                                          e,
                                          type: UpdateSearchHistoryType.remove,
                                        );
                                        break;
                                      default:
                                    }
                                  },
                                ),
                              )
                              .toList(),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<MirrorOnceItemSerialize>> handleSearch(String? text) async {
    if (text == null) return [];
    home.handleUpdateSearchHistory(
      text,
      type: UpdateSearchHistoryType.add,
    );
    var data = await home.updateSearchData(text);
    return data;
  }
}
