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

  String get playfulConfirmText {
    return "我知道了";
  }

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
      showEasyCupertinoDialog(
        context: ctx,
        content: Html(data: element.msg ?? ""),
        title: element.title,
        confirmText: playfulConfirmText,
        onDone: () {
          Get.back();
          completer.complete();
        },
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
    await FlutterClipboard.copy(result);
    showEasyCupertinoDialog(content: '已复制到剪贴板!');
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
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'json',
        'txt',
      ],
    );

    if (result == null) {
      showEasyCupertinoDialog(
        content: "未选择文件 :(",
        confirmText: playfulConfirmText,
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
      showEasyCupertinoDialog(
        content: "导入的文件格式错误 :(",
        confirmText: playfulConfirmText,
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
      dynamic jsonData = jsonDecode(source);
      if (typeAs == JSONBodyType.array) {
        List<dynamic> cache = jsonData as List<dynamic>;
        var cacheAsMap = cache.map((item) {
          return item as Map<String, dynamic>;
        }).toList();
        pending.addAll(cacheAsMap);
      } else {
        /// 兼容 https://github.com/waifu-project/assets/blob/master/db.json
        ///
        /// ```json
        /// {
        ///   "mirrors": []
        /// }
        /// ```
        var BIND_KEY = 'mirrors';
        var jsonDataAsMap = jsonData as Map<String, dynamic>;
        if (jsonDataAsMap.containsKey(BIND_KEY)) {
          var cache = jsonDataAsMap[BIND_KEY];
          if (cache is List) {
            List<Map<String, dynamic>> cacheAsMapList = cache
                .map((item) {
                  if (item is Map<String, dynamic>) return item;
                  return null;
                })
                .toList()
                .where((element) => element != null)
                .toList()
                .map((e) => e as Map<String, dynamic>)
                .toList();
            pending.addAll(cacheAsMapList);
          }
        }

        pending.add(jsonDataAsMap);
      }
      var result = pending
          .map((e) {
            return SourceUtils.parse(e);
          })
          .toList()
          .where((element) {
            return element != null;
          })
          .toList()
          .map((e) => e as KBaseMirrorMovie)
          .toList();
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
      showEasyCupertinoDialog(
        content: "未导入源, 可能是JSON文件格式不对? :(",
        confirmText: playfulConfirmText,
      );
      return;
    } else {
      var newListData = SourceUtils.mergeMirror(stack);
      await MirrorManage.mergeMirror(newListData);
      showEasyCupertinoDialog(
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
        confirmText: "好耶ヾ(✿ﾟ▽ﾟ)ノ",
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

showEasyCupertinoDialog({
  String? title,
  dynamic content,
  VoidCallback? onDone,
  BuildContext? context,
  String? confirmText,
}) {
  Widget child = SizedBox.shrink();
  String outputTitle = title ?? "提示";
  String outputConfrimText = confirmText ?? "确定";
  if (content is Widget) {
    child = content;
  } else if (content is String) {
    child = Text(content);
  }
  var ctx = Get.context as BuildContext;
  if (context != null) ctx = context;
  showCupertinoDialog(
    builder: (BuildContext context) => easyShowModalWidget(
      content: child,
      title: outputTitle,
      onDone: onDone,
      confirmText: outputConfrimText,
    ),
    context: ctx,
  );
}

class easyShowModalWidget extends StatelessWidget {
  const easyShowModalWidget({
    Key? key,
    this.onDone,
    required this.content,
    this.title = "提示",
    this.confirmText = "确定",
    this.confirmTextColor = Colors.red,
  }) : super(key: key);

  final VoidCallback? onDone;
  final String title;
  final Widget content;
  final String confirmText;
  final Color confirmTextColor;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Column(
        children: [
          Text(title),
        ],
      ),
      content: content,
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          child: Text(
            confirmText,
            style: TextStyle(
              color: confirmTextColor,
            ),
          ),
          onPressed: () {
            if (onDone != null) {
              onDone!();
            } else {
              Get.back();
            }
          },
        ),
      ],
    );
  }
}
