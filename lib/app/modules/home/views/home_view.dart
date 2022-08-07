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

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:movie/app/modules/home/views/home_config.dart';
import 'package:movie/app/modules/home/views/index_home_view.dart';
import 'package:movie/app/modules/home/views/search_view.dart';
import 'package:movie/app/modules/home/views/settings_view.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  bool get isDark => Get.isDarkMode;

  final List<Widget> _views = [
    IndexHomeView(),
    SearchView(),
    SettingsView(),
  ];

  final List<Map<String, dynamic>> _tabs = [
    {
      "icon": CupertinoIcons.home,
      "title": "首页",
      "color": Colors.blue,
    },
    {
      "icon": CupertinoIcons.search,
      "title": "搜索",
      "color": Colors.orange,
    },
    {
      "icon": CupertinoIcons.settings,
      "title": "设置",
      "color": Colors.pink,
    },
  ];

  Color get _color => isDark
      ? Color.fromRGBO(0, 0, 0, .63)
      : Color.fromRGBO(255, 255, 255, .63);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeview) => Scaffold(
        body: PageView.builder(
          controller: homeview.currentBarController,
          itemBuilder: (context, index) {
            return _views[index];
          },
          itemCount: _views.length,

          // NOTE:
          // => 2022年/05月/14日 14:51
          // => 滑动的实在太生硬了
          // => 而且在桌面端会和窗口拖动冲突
          // => 所以放弃了滚动
          physics: NeverScrollableScrollPhysics(),

          onPageChanged: (index) {

            // fix ios keyboard auto up
            var currentFocus = FocusScope.of(context);
            currentFocus.unfocus();

            homeview.changeCurrentBarIndex(index);
          },
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          color: _color,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: kBarHeight,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 360,
                      ),
                      child: SalomonBottomBar(
                        itemPadding: EdgeInsets.symmetric(
                          vertical: 9,
                          horizontal: 18,
                        ),
                        currentIndex: homeview.currentBarIndex,
                        onTap: (int i) {
                          homeview.changeCurrentBarIndex(i);
                        },
                        items: _tabs
                            .map(
                              (e) => SalomonBottomBarItem(
                                icon: Icon(e['icon']),
                                title: Text(e['title']),
                                selectedColor: e['color'],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        extendBody: true,
      ),
    );
  }
}
