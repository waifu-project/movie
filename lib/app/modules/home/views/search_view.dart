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

import 'package:dio/dio.dart';
import 'package:flappy_search_bar_ns/flappy_search_bar_ns.dart';
import 'package:flappy_search_bar_ns/search_bar_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/routes/app_pages.dart';
import 'package:movie/app/widget/helper.dart';
import 'package:movie/app/widget/k_empty_mirror.dart';
import 'package:movie/app/widget/k_error_stack.dart';
import 'package:movie/app/widget/k_pagination.dart';
import 'package:movie/app/widget/k_tag.dart';
import 'package:movie/app/widget/window_appbar.dart';
import 'package:movie/config.dart';
import 'package:movie/mirror/mirror_serialize.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with AutomaticKeepAliveClientMixin {
  final HomeController home = Get.find<HomeController>();

  SearchBarController get _searchBarController => home.searchBarController;

  List<String> _searchHistory = [];

  List<String> get searchHistory {
    return _searchHistory;
  }

  set searchHistory(newVal) {
    setState(() {
      _searchHistory = newVal;
    });
    home.localStorage.write(ConstDart.search_history, newVal);
  }

  loadSearchHistory() {
    var data = List<String>.from(
      home.localStorage.read(ConstDart.search_history) ?? [],
    );
    setState(() {
      _searchHistory = data;
    });
  }

  @override
  void initState() {
    loadSearchHistory();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// ??????????????????
  handleUpdateSearchHistory(
    String text, {
    type = UpdateSearchHistoryType.add,
  }) {
    var oldData = _searchHistory;
    switch (type) {
      case UpdateSearchHistoryType.add: // ??????
        oldData.remove(text);
        oldData.insert(0, text);
        break;
      case UpdateSearchHistoryType.remove: // ????????????
        oldData.remove(text);
        break;
      case UpdateSearchHistoryType.clean: // ????????????
        oldData = [];
        break;
      default:
    }
    searchHistory = oldData;
  }

  int _page = 1;

  int get page => _page;

  set page(int newVal) {
    setState(() {
      _page = newVal;
    });
    if (newVal == textEditingControllerIntValue) return;
    changeTextEditingController(newVal);
  }

  int limit = 20;

  int cacheDataLength = 10;

  bool isTriggerSearch = false;

  String cacheSearchText = "";

  TextEditingController textEditingController =
      TextEditingController(text: "1");

  changeTextEditingController(int text) {
    textEditingController.text = text.toString();
  }

  int get textEditingControllerIntValue =>
      int.parse(textEditingController.text);

  /// ?????? `logo`
  String get _defaultLogo => home.currentMirrorItem.meta.logo;

  bool get showEmptyStack {
    return home.mirrorListIsEmpty;
  }

  PreferredSizeWidget? get _appBar {
    bool isDesktop = GetPlatform.isDesktop;
    if (isDesktop) {
      return WindowAppBar(
        centerTitle: showEmptyStack,
        title: Builder(builder: (context) {
          if (showEmptyStack)
            return Text(
              "??????",
              style: TextStyle(
                fontSize: 18,
              ),
            );
          return SizedBox.shrink();
        }),
      );
    }
    return null;
  }

  double get _kEmptyMirrorWidth {
    var width = home.windowLastSize.width;
    if (width >= 500) return 120;
    return width * .6;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<HomeController>(
      builder: (home) {
        return Scaffold(
          appBar: _appBar,
          body: SafeArea(
            child: Builder(builder: (context) {
              if (showEmptyStack) {
                return KEmptyMirror(
                  width: _kEmptyMirrorWidth,
                );
              }
              return SearchBar<MirrorOnceItemSerialize>(
                textStyle: TextStyle(
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                ),
                searchBarController: _searchBarController,
                header: Builder(builder: (context) {
                  if (!canShowPagingView) return SizedBox.shrink();
                  return KPagination(
                    turnL: isPrevPage,
                    turnR: isNextPage,
                    textEditingController: textEditingController,
                    onActionTap: (KPaginationActionButtonDirection type) {
                      setState(() {
                        switch (type) {
                          case KPaginationActionButtonDirection.l:
                            page--;
                            break;
                          case KPaginationActionButtonDirection.r:
                            page++;
                            break;
                          default:
                        }
                      });
                      handleStandSearch(
                        isInit: false,
                      );
                    },
                    onJumpTap: () {
                      if (page == textEditingControllerIntValue) return;
                      setState(() {
                        page = textEditingControllerIntValue;
                      });
                      handleStandSearch();
                    },
                  );
                }),
                onItemFound: (item, int index) {
                  String? _targetImage = item?.smallCoverImage;

                  /// ?????? [item?.smallCoverImage] ??? [_defaultLogo] ???????????????????????????????????????
                  bool canNotFindCover = _targetImage == _defaultLogo;

                  double w = 90;

                  double h = 100;

                  Widget coverWidget = Image.network(
                    _targetImage ?? _defaultLogo,
                    width: w,
                    height: h,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: child,
                        );
                      }
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
                  );

                  // EdgeInsets _sharkPadding = EdgeInsets.all(canNotFindCover ? 10 : 0);

                  if (canNotFindCover) {
                    coverWidget = SizedBox.shrink();
                  }

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
                        vertical: 24,
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          coverWidget,
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: Text(
                                item?.title ?? "",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
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
                onSearch: (String? text) {
                  setState(() {
                    page = 1;
                  });
                  return handleSearch(text);
                },
                emptyWidget: Center(
                  child: Text("??????????????????"),
                ),
                onError: (error) {
                  return KErrorStack(
                    msg: error.toString(),
                  );
                },
                cancellationWidget: Text("??????"),
                onCancelled: () {
                  setState(() {
                    isTriggerSearch = false;
                  });
                },
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
                                  "????????????",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ],
                            ),
                            IconButton(
                              tooltip: "????????????????????????",
                              padding: EdgeInsets.symmetric(
                                vertical: 3,
                                horizontal: 2,
                              ),
                              onPressed: () {
                                handleUpdateSearchHistory(
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
                        searchHistory.isEmpty
                            ? Text(
                                "??????????????????",
                                style: Theme.of(context).textTheme.subtitle2,
                              )
                            : Wrap(
                                children: searchHistory
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
                                            case KTagTapEventType.content: // ??????
                                              handleUpdateSearchHistory(
                                                e,
                                                type: UpdateSearchHistoryType.add,
                                              );
                                              handleStandSearch(title: e);
                                              break;
                                            case KTagTapEventType.action: // action
                                              handleUpdateSearchHistory(
                                                e,
                                                type:
                                                    UpdateSearchHistoryType.remove,
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
              );
            }),
          ),
        );
      }
    );
  }

  /// [isInit] ??????????????????, ??? [page] => 1
  ///
  /// [title] ???????????????????????????????????? [cacheSearchText]
  handleStandSearch({
    String? title,
    bool isInit = true,
  }) {
    if (isInit) {
      setState(() {
        page = 1;
      });
    }
    var outputTitle = cacheSearchText;
    if (title != null) outputTitle = title;
    return _searchBarController.injectSearch(
      outputTitle,
      handleSearch,
    );
  }

  /// ?????? [MovieImpl] ????????????????????????????????? [List<MirrorOnceItemSerialize>]
  /// ??????????????????????????????????????????, ????????????????????????????????????
  /// [ 10, 20 ] (??????????????? [limit] ????????????)
  bool get isNextPage {
    return [10, 20].any((element) => element == cacheDataLength);
  }

  bool get isPrevPage {
    return page >= 2;
  }

  bool get canShowPagingView {
    return (isNextPage || isPrevPage) && isTriggerSearch;
  }

  /// ????????????????????? [page]
  /// [isInitPage]
  Future<List<MirrorOnceItemSerialize>> handleSearch(String? text) async {
    try {
      if (text == null) return [];
      setState(() {
        isTriggerSearch = true;
        cacheSearchText = text;
      });
      handleUpdateSearchHistory(
        text,
        type: UpdateSearchHistoryType.add,
      );
      var data = await home.updateSearchData(text, page: page, limit: limit);
      setState(() {
        cacheDataLength = data.length;
      });
      return data;
    } on DioError catch (dioError) {
      setState(() {
        isTriggerSearch = false;
      });
      throw AsyncError(dioError, StackTrace.fromString(dioError.error));
    }
  }

  @override
  bool get wantKeepAlive => true;
}
