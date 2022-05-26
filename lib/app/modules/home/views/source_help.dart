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
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:movie/app/modules/home/views/home_config.dart';
import 'package:movie/app/widget/k_error_stack.dart';
import 'package:movie/app/widget/window_appbar.dart';
import 'package:movie/mirror/m_utils/m.dart';
import 'package:movie/mirror/m_utils/source_utils.dart';
import 'package:movie/mirror/mirror.dart';
import 'package:movie/utils/helper.dart';
import 'package:movie/utils/http.dart';
import 'package:clipboard/clipboard.dart';
import 'package:movie/utils/json.dart';

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

  /// 导入文件
  handleImportFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, type: FileType.custom,
      // TODO support `.txt`
      allowedExtensions: [
        'json',
        'txt',
      ],
    );

    if (result == null) {
      showCupertinoDialog(
        builder: (context) => CupertinoAlertDialog(
          content: Text("未选择文件 :("),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                '我知道了',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
        context: context,
      );
      return;
    }
    List<File> files = result.paths.map((path) => File(path!)).toList();

    // ==========================
    var SOURCE_KEY = "source";
    var FILENAME_KEY = "filename";
    // ==========================

    var data = files
        .where((e) => !isBinaryAsFile(e))
        .toList()
        .map<Map<String, dynamic>>((item) {
          String filename = item.uri.pathSegments.last;
          return {
            SOURCE_KEY: item.readAsStringSync(),
            FILENAME_KEY: filename,
          };
        })
        .toList()
        .where((e) => verifyStringIsJSON(e[SOURCE_KEY] as String))
        .toList();
    if (data.isEmpty) {
      showCupertinoDialog(
        builder: (context) => CupertinoAlertDialog(
          content: Text("导入的文件格式错误 :("),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                '我知道了',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
        context: context,
      );
      return;
    }
    var _collData = new Map<String, List<KBaseMirrorMovie>>();
    data.forEach((item) {
      String source = item[SOURCE_KEY] as String;
      String filename = item[FILENAME_KEY] as String;
      var typeAs = getJSONBodyType(source);
      if (typeAs == null) return;
      List<Map<String, dynamic>> pending = [];
      if (typeAs == JSONBodyType.array) {
        List<dynamic> cache = jsonDecode(source) as List<dynamic>;
        var cacheAsMap = cache.map((item) {
          return item as Map<String, dynamic>;
        }).toList();
        pending.addAll(cacheAsMap);
      } else {
        pending.add(jsonDecode(source));
      }
      var result = pending.map((e) => SourceUtils.parse(e)).toList();
      _collData[filename] = result;
    });

    String easyMessage = "";
    List<KBaseMirrorMovie> stack = [];
    _collData.forEach((k, v) async {
      int len = v.length;
      if (v.isNotEmpty) {
        stack.addAll(v);
        easyMessage += "从$k中导入了$len个源\n";
      }
    });
    if (stack.isEmpty) {
      showCupertinoDialog(
        builder: (context) => CupertinoAlertDialog(
          content: Text("未导入源, 可能是JSON文件格式不对? :("),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                '我知道了',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
        context: context,
      );
      return;
    } else {
      var newListData = SourceUtils.mergeMirror(stack);
      await MirrorManage.mergeMirror(newListData);
      showCupertinoDialog(
        builder: (context) => CupertinoAlertDialog(
          content: Column(
            children: [
              Icon(
                CupertinoIcons.hand_thumbsup,
                size: 51,
                color: CupertinoColors.systemBlue,
              ),
              SizedBox(
                height: 24,
              ),
              Text(easyMessage),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                '好耶ヾ(✿ﾟ▽ﾟ)ノ',
                style: TextStyle(
                  color: CupertinoColors.systemBlue,
                ),
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoEasyAppBar(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoNavigationBarBackButton(),
                  Text(
                    "o(-`д´- ｡)",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 12,
                    ),
                    child: CupertinoButton.filled(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.arrow_down_square_fill,
                            color: CupertinoColors.white,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            "导入文件",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyText1!.copyWith(
                                  color: CupertinoColors.white,
                                ),
                          ),
                        ],
                      ),
                      onPressed: handleImportFiles,
                    ),
                  ),
                ],
              ),
              Divider()
            ],
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
