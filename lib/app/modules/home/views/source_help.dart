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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:movie/app/modules/home/views/home_config.dart';
import 'package:movie/app/widget/k_error_stack.dart';
import 'package:movie/utils/http.dart';
import 'package:clipboard/clipboard.dart';

import 'package:movie/widget/list_tile.dart';

class SourceItemJSONData {
  String? title;
  String? url;
  String? msg;

  SourceItemJSONData({
    this.title,
    this.url,
    this.msg,
  });

  SourceItemJSONData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    url = json['url'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['url'] = this.url;
    data['msg'] = this.msg;
    return data;
  }
}

class SourceHelpTable extends StatefulWidget {
  const SourceHelpTable({Key? key}) : super(key: key);

  @override
  _SourceHelpTableState createState() => _SourceHelpTableState();
}

class _SourceHelpTableState extends State<SourceHelpTable> {
  int _tabIndex = 0;

  int get tabIndex => _tabIndex;

  set tabIndex(int newVal) {
    setState(() {
      _tabIndex = newVal;
    });
    pageController.animateToPage(
      newVal,
      duration: Duration(milliseconds: 420),
      curve: Curves.ease,
    );
  }

  loadMirrorListApi() async {
    setState(() {
      _isLoadingFromAJAX = true;
    });
    try {
      // if (kDebugMode) await Future.delayed(Duration(seconds: 2));
      var resp = await XHttp.dio.get(FetchMirrorAPI);
      List<SourceItemJSONData> data = List.from(resp.data)
          .map((e) => SourceItemJSONData.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        mirrors = data;
        _isLoadingFromAJAX = false;
        _loadingErrorStack = "";
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoadingFromAJAX = false;
        _loadingErrorStack = e.toString();
      });
    }
  }

  bool _isLoadingFromAJAX = false;

  String _loadingErrorStack = "";

  List<SourceItemJSONData> mirrors = [];

  @override
  void initState() {
    super.initState();
    loadSourceCreateData();
    loadMirrorListApi();
  }

  PageController pageController = PageController();

  handleCopyText({
    SourceItemJSONData? item,
    bool canCopyAll = false,
  }) async {
    List<SourceItemJSONData> actions = mirrors;
    if (!canCopyAll && item != null) actions = [item];
    var ctx = Get.context;
    if (ctx == null) return;
    await Future.forEach(actions, (SourceItemJSONData element) {
      var msg = element.msg ?? "";
      Completer completer = Completer();
      if (msg.isEmpty) {
        completer.complete();
        return completer.future;
      }
      showCupertinoDialog(
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(element.title ?? ""),
          content: Html(data: element.msg ?? ""),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: const Text(
                '我知道了',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Get.back();
                completer.complete();
              },
            ),
          ],
        ),
        context: ctx,
      );
      return completer.future;
    });

    String result = actions[0].url ?? "";

    if (canCopyAll) {
      result = "";
      actions.forEach((element) {
        result += '${element.url}\n';
      });
    }
    if (result.isEmpty) return;
    FlutterClipboard.copy(result).then(
      (value) {
        Get.showSnackbar(
          GetBar(
            message: "已复制到剪贴板!",
            duration: Duration(seconds: 1),
          ),
        );
      },
    );
  }

  loadSourceCreateData() async {
    var data = await rootBundle.loadString("assets/data/source_create.html");
    setState(() {
      sourceCreateData = data;
    });
  }

  String sourceCreateData = "";

  String get _wrapperAjaxStatusLable {
    if (!_isLoadingFromAJAX) return "啥也没有";
    return "加载网络资源中";
  }

  /// 判断加载失败
  bool get _canLoadFail {
    return _loadingErrorStack.isNotEmpty && !_isLoadingFromAJAX;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
          middle: Text(
            "o(-`д´- ｡)",
            style:
                TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black),
          ),
        ),
        child: SafeArea(
          child: Container(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 6,
                  ),
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl(
                    backgroundColor: Colors.black26,
                    thumbColor: Get.isDarkMode ? Colors.blue : Colors.white,
                    onValueChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        tabIndex = value as int;
                      });
                    },
                    groupValue: tabIndex,
                    children: <int, Widget>{
                      0: Text("推荐源"),
                      1: Text("制作教程"),
                    },
                  ),
                ),
                Expanded(
                  child: PageView(
                    onPageChanged: (index) {
                      setState(() {
                        tabIndex = index;
                      });
                    },
                    controller: pageController,
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: CupertinoScrollbar(
                              child: Builder(
                                builder: (context) {
                                  if (mirrors.isEmpty) {
                                    Widget _child =
                                        Text(_wrapperAjaxStatusLable);
                                    if (_canLoadFail)
                                      _child = KErrorStack(
                                        msg: _loadingErrorStack,
                                      );
                                    return Center(
                                      child: _child,
                                    );
                                  }
                                  return ListView(
                                    children: [
                                      ...mirrors.map((item) {
                                        return CupertinoListTile(
                                          title: Text(
                                            item.title ?? "",
                                            style: TextStyle(
                                              color: Get.isDarkMode
                                                  ? Colors.white54
                                                  : Colors.black54,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          onTap: () {
                                            handleCopyText(item: item);
                                          },
                                        );
                                      }).toList(),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              if (mirrors.isEmpty) {
                                if (_canLoadFail)
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 24,
                                    ),
                                    child: CupertinoButton.filled(
                                      padding: EdgeInsets.all(12),
                                      child: Text("重新加载"),
                                      onPressed: () {
                                        loadMirrorListApi();
                                      },
                                    ),
                                  );
                                return SizedBox.shrink();
                              }
                              return Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 12,
                                ),
                                child: CupertinoButton.filled(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Text("一键复制到剪贴板"),
                                  onPressed: () {
                                    handleCopyText(canCopyAll: true);
                                  },
                                ),
                              );
                            },
                          )
                        ],
                      ),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (sourceCreateData.isEmpty)
                              return Center(
                                child: Text("(;｀O´)o"),
                              );
                            return ListView(
                              children: [
                                Html(
                                  data: sourceCreateData,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
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
