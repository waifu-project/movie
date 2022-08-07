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

// 开启 `nsfw`

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/widget/window_appbar.dart';

import 'settings_view.dart';

class NsfwTableView extends StatefulWidget {
  const NsfwTableView({Key? key}) : super(key: key);

  @override
  _NsfwTableViewState createState() => _NsfwTableViewState();
}

class _NsfwTableViewState extends State<NsfwTableView> {
  final HomeController home = Get.find<HomeController>();

  Future<String> loadNsfwAsset() async {
    return await rootBundle.loadString('assets/data/nsfw.html');
  }

  TextEditingController c1 = TextEditingController(text: "");
  TextEditingController c2 = TextEditingController(text: "");

  String c1Value = "";

  String c2Value = "";

  bool get canInputNext {
    var _1 = c1Value == '2';
    var _2 = c2Value == '3';
    return _1 && _2;
  }

  String html = "";

  @override
  void initState() {
    c1.addListener(() {
      setState(() {
        c1Value = c1.text;
      });
    });
    c2.addListener(() {
      setState(() {
        c2Value = c2.text;
      });
    });
    loadHtmlCode();
    super.initState();
  }

  loadHtmlCode() async {
    var data = await loadNsfwAsset();
    setState(() {
      html = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoEasyAppBar(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoNavigationBarBackButton(),
                Expanded(
                  child: Text(
                    '开启NSFW',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Divider(),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(html),
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "为了确定您已经未成年, 请完成一道数学题之后开启:  ",
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headline6?.fontSize ??
                                21,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "某个住在湖边的老人养有狗和鸭子，某天，老人看到5个头、14只脚。那么老人看到的是多少条狗？多少只鸭子？",
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodyText2?.fontSize ??
                                12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      "狗子: ",
                      style: TextStyle(
                        decoration: TextDecoration.none,
                      ),
                    ),
                    CupertinoTextField(
                      controller: c1,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: Get.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "鸭子: ",
                      style: TextStyle(
                        decoration: TextDecoration.none,
                      ),
                    ),
                    CupertinoTextField(
                      controller: c2,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: Get.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    canInputNext
                        ? Center(
                            child: CupertinoButton(
                              color: Colors.red,
                              child: Text("开启"),
                              onPressed: () {
                                Get.back(
                                  result: GetBackResultType.success,
                                );
                              },
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(
                      height: Get.height * .42,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
