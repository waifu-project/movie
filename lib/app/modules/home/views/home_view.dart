import 'dart:ui';

import 'package:command_palette/command_palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/home/views/index_home_view.dart';
import 'package:catmovie/app/modules/home/views/search_view.dart';
import 'package:catmovie/app/modules/home/views/settings_view.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:xi/xi.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  final List<Widget> _views = [
    const IndexHomeView(),
    const SearchView(),
    const SettingsView(),
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

  List<ISpiderAdapter> get mirror => controller.mirrorList;

  int get mirrorIndex => controller.mirrorIndex;

  @override
  Widget build(BuildContext context) {
    bool isDark = context.isDarkMode;
    Color color = isDark
        ? const Color.fromRGBO(0, 0, 0, .63)
        : const Color.fromRGBO(255, 255, 255, .63);
    return GetBuilder<HomeController>(
      builder: (homeview) => CommandPalette(
        focusNode: controller.focusNode,
        config: CommandPaletteConfig(
          transitionCurve: Curves.easeOutQuart,
          style: CommandPaletteStyle(
            barrierFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            actionLabelTextAlign: TextAlign.left,
            borderRadius: BorderRadius.circular(12),
            textFieldInputDecoration: const InputDecoration(
              hintText: "今天要做什么呢?",
              contentPadding: EdgeInsets.all(16),
            ),
          ),
          showInstructions: true,
        ),
        onTabSwitch: controller.switchTabview,
        onClose: () {
          if (homeview.currentBarIndex == 0) {
            Future.delayed(const Duration(milliseconds: 100), () {
              controller.focusNode.requestFocus();
              controller.homeFocusNode.requestFocus();
            });
          }
        },
        actions: [
          CommandPaletteAction.nested(
            label: "切换镜像",
            leading: const Icon(CupertinoIcons.book_circle, size: 26),
            childrenActions: mirror.map((e) {
              var currIndex = mirror.indexOf(e);
              return CommandPaletteAction.single(
                label: e.meta.name,
                description: currIndex == controller.mirrorIndex ? '当前使用' : '',
                onSelect: () {
                  var idx = mirror.indexOf(e);
                  controller.updateMirrorIndex(idx);
                  Get.back();
                },
              );
            }).toList(),
          ),
          CommandPaletteAction.single(
            label: context.isDarkMode ? "切换亮色主题" : "切换暗色主题",
            leading: Text(
              context.isDarkMode ? "🌃" : "🌇",
              style: const TextStyle(fontSize: 24),
            ),
            onSelect: () {
              var newTheme = !context.isDarkMode
                  ? SystemThemeMode.dark
                  : SystemThemeMode.light;
              updateSetting(SettingsAllKey.themeMode, newTheme);
              Get.changeThemeMode(
                  !context.isDarkMode ? ThemeMode.dark : ThemeMode.light);
              controller.update();
            },
          )
        ],
        child: Scaffold(
          body: PageView.builder(
            controller: homeview.currentBarController,
            itemBuilder: (context, index) {
              return _views[index];
            },
            itemCount: _views.length,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              // fix ios keyboard auto up
              var currentFocus = FocusScope.of(context);
              currentFocus.unfocus();
              controller.focusNode.requestFocus();
              homeview.changeCurrentBarIndex(index);
            },
          ),
          bottomNavigationBar: BottomAppBar(
            elevation: 0,
            color: color,
            padding: EdgeInsets.zero,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 63,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 360,
                        ),
                        child: SalomonBottomBar(
                          itemPadding: const EdgeInsets.symmetric(
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
      ),
    );
  }
}
