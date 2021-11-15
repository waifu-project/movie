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

import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:movie/app/modules/home/views/home_config.dart';
import 'package:movie/utils/http.dart';
import 'package:clipboard/clipboard.dart';

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
    try {
      var resp = await XHttp.dio.get(FetchMirrorAPI);
      List<String> data = List<String>.from(resp.data);
      setState(() {
        mirrors = data;
      });
    } catch (e) {
      print(e);
    }
  }

  List<String> mirrors = [];

  @override
  void initState() {
    super.initState();
    loadSourceCreateData();
    loadMirrorListApi();
  }

  PageController pageController = PageController();

  handleCopyText({
    String? item,
    bool canCopyAll = false,
  }) {
    String result = item ?? "";
    if (canCopyAll) {
      result = "";
      mirrors.forEach((element) {
        result += '$element\n';
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
                    controller: pageController,
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: CupertinoScrollbar(
                              child: Builder(
                                builder: (context) {
                                  if (mirrors.isEmpty)
                                    return Center(
                                      child: Text("啥也没有"),
                                    );
                                  return ListView(
                                    children: [
                                      ...mirrors.map((item) {
                                        return CupertinoListTile(
                                          title: Text(
                                            item,
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
                              if (mirrors.isEmpty) return SizedBox.shrink();
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
