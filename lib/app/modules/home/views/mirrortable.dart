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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/widget/helper.dart';
import 'package:movie/impl/movie.dart';
import 'package:movie/mirror/mirror.dart';

class MirrorTableView extends StatefulWidget {
  const MirrorTableView({Key? key}) : super(key: key);

  @override
  _MirrorTableViewState createState() => _MirrorTableViewState();
}

class _MirrorTableViewState extends State<MirrorTableView> {
  final HomeController home = Get.find<HomeController>();

  List<MovieImpl> get _mirrorList {
    return home.mirrorList;
  }

  List<MovieImpl> mirrorList = [];

  ScrollController scrollController = ScrollController(
    initialScrollOffset: 0,
    keepScrollOffset: true,
  );

  double get cacheMirrorTableScrollControllerOffset {
    return home.cacheMirrorTableScrollControllerOffset;
  }

  updateCacheMirrorTableScrollControllerOffset() {
    Future.delayed(Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(
          cacheMirrorTableScrollControllerOffset,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      double offset = scrollController.offset;
      home.updateCacheMirrorTableScrollControllerOffset(offset);
    });
    updateCacheMirrorTableScrollControllerOffset();
    setState(() {
      mirrorList = _mirrorList;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Get.isDarkMode ? Colors.black12 : Colors.white,
        leading: GetPlatform.isDesktop
            ? CupertinoNavigationBarBackButton()
            : Container(),
        middle: Text(
          '视频源',
          style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      child: SafeArea(
        child: Scrollbar(
          child: ListView(
            controller: scrollController,
            children: mirrorList
                .map(
                  (e) => mirrorCard(
                    item: e,
                    current: home.currentMirrorItem == e,
                    onTap: () {
                      var index = mirrorList.indexOf(e);
                      home.updateMirrorIndex(index);
                      Get.back();
                    },
                    onDel: (context) {
                      showCupertinoDialog(
                        builder: (context) => CupertinoAlertDialog(
                          content: Text("是否删除该镜像源?"),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text(
                                '我想想',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                            CupertinoDialogAction(
                              child: const Text(
                                '删除',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  mirrorList.remove(e);
                                });
                                home.removeMirrorItemSync(e);
                                MirrorManage.removeItem(e);
                                Get.back();
                              },
                            ),
                          ],
                        ),
                        context: context,
                      );
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class mirrorCard extends StatelessWidget {
  const mirrorCard({
    Key? key,
    required this.item,
    this.current = false,
    required this.onTap,
    this.onDel,
  }) : super(key: key);

  final MovieImpl item;

  final bool current;

  final SlidableActionCallback? onDel;

  final VoidCallback onTap;

  String get _logo => item.meta.logo;

  String get _title => item.meta.name;

  String get _desc => item.meta.desc;

  /// [current] 当前的不能删除
  /// [MirrorManage.builtin] 内建的源不可删除
  bool get enabled {
    bool isBuiltin = MirrorManage.builtin.any((element) => element == item);
    return !current && !isBuiltin;
  }

  /// 如果是 [MovieImpl.isNsfw] => [Colors.red]
  /// 如果是 [current] => [Colors.blue] (优先级高一点)
  Color get _color {
    if (current) return Colors.blue;
    return item.isNsfw
        ? Colors.red
        : (Get.isDarkMode ? Colors.white : Colors.black45);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Slidable(
        enabled: enabled,
        key: ObjectKey(item),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          // TODO
          // 滑动可关闭
          // dismissible: DismissiblePane(
          //   confirmDismiss: () async {
          //     return false;
          //   },
          //   onDismissed: () {},
          // ),
          children: [
            SlidableAction(
              onPressed: onDel,
              backgroundColor: Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: CupertinoIcons.delete,
              label: '删除',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Get.isDarkMode
                          ? Colors.white.withOpacity(.1)
                          : Colors.black.withOpacity(.1))),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 6,
            ),
            child: Row(children: [
              Container(
                width: 92,
                margin: EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 2,
                ),
                child: Builder(builder: (_) {
                  if (_logo.isEmpty) {
                    return Image.asset(
                      "assets/images/fishtank.png",
                      width: 60,
                      height: 42,
                    );
                  }
                  return Card(
                    shadowColor: Colors.black.withOpacity(.1),
                    child: Container(
                      width: 60,
                      height: 42,
                      child: CachedNetworkImage(
                        imageUrl: _logo,
                        fit: BoxFit.fitWidth,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (
                          context,
                          url,
                          error,
                        ) =>
                            Image.asset(
                          K_DEFAULT_IMAGE,
                          width: 80,
                          height: 42,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title,
                            style: TextStyle(
                              color: _color,
                              fontSize: 14,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(
                            height: _desc.isEmpty ? 0 : 3,
                          ),
                          _desc.isEmpty
                              ? SizedBox.shrink()
                              : Text(
                                  _desc,
                                  style: TextStyle(
                                    color: _color,
                                    fontSize: 9,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  maxLines: 2,
                                ),
                        ],
                      ),
                    ),
                    Icon(
                      current ? Icons.done : CupertinoIcons.right_chevron,
                      color: _color,
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
