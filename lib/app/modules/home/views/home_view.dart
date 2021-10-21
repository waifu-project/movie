import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:movie/app/modules/home/views/home_config.dart';
import 'package:movie/app/modules/home/views/index_home_view.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  // final homeview = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeview) => Scaffold(
        appBar: AppBar(
          title: Text('movie'),
          centerTitle: false,
        ),
        body: AnimatedSwitcher(
          duration: Duration(
            milliseconds: 200,
          ),
          child: IndexedStack(
            key: ValueKey<int>(homeview.currentBarIndex),
            children: [
              IndexHomeView(),
              Text("2"),
              Text("3"),
            ],
            index: homeview.currentBarIndex,
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          color: Color.fromRGBO(255, 255, 255, .63),
          child: SizedBox(
            height: kBarHeight,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
