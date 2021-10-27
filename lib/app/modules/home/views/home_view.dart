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
  
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeview) => Scaffold(
        body: AnimatedSwitcher(
          duration: Duration(
            milliseconds: 200,
          ),
          child: IndexedStack(
            key: ValueKey<int>(homeview.currentBarIndex),
            children: [
              IndexHomeView(),
              SearchView(),
              SettingsView(),
            ],
            index: homeview.currentBarIndex,
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          color: isDark ? Color.fromRGBO(0, 0, 0, .63) : Color.fromRGBO(255, 255, 255, .63),
          child: SizedBox(
            height: kBarHeight,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: SalomonBottomBar(
                  itemPadding: EdgeInsets.symmetric(
                    vertical: 9,
                    horizontal: 32,
                  ),
                  currentIndex: homeview.currentBarIndex,
                  onTap: (int i) {
                    homeview.changeCurrentBarIndex(i);
                  },
                  items: [
                    SalomonBottomBarItem(
                      icon: Icon(CupertinoIcons.home),
                      title: Text("首页"),
                      selectedColor: Colors.blue,
                    ),
                    SalomonBottomBarItem(
                      icon: Icon(CupertinoIcons.search),
                      title: Text("搜索"),
                      selectedColor: Colors.orange,
                    ),
                    SalomonBottomBarItem(
                      icon: Icon(CupertinoIcons.settings),
                      title: Text("设置"),
                      selectedColor: Colors.pink,
                    ),
                  ],
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
