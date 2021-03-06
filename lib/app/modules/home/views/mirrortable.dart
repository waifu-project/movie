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
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/modules/home/views/mirror_check.dart';
import 'package:movie/app/shared/mirror_status_stack.dart';
import 'package:movie/app/widget/wechat_popmenu.dart';
import 'package:movie/app/widget/window_appbar.dart';
import 'package:movie/impl/movie.dart';
import 'package:movie/mirror/mirror.dart';
import 'package:movie/utils/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum MenuActionType {
  /// 检测源
  check,

  /// 删除不可用源
  delete_unavailable,

  /// 导出
  export,
}

class ItemModel {
  String title;
  IconData icon;
  MenuActionType action;

  ItemModel(
    this.title,
    this.icon,
    this.action,
  );
}

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

  updateCacheMirrorTableScrollControllerOffset([bool isFirst = true]) {
    if (isFirst && cacheMirrorTableScrollControllerOffset <= 0) return;
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
    updateCacheMirrorTableScrollControllerOffset(true);
    updateMirrorStatusMap();
    setState(() {
      mirrorList = _mirrorList;
    });
  }

  updateMirrorStatusMap() {
    __statusMap = MirrorStatusStack().getStacks;
    setState(() {});
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  /// 标题
  String get _title {
    var count = mirrorList.length;
    return "视频源管理(${count})";
  }

  var menuItems = [
    ItemModel(
      '批量检测源',
      Icons.chat_bubble,
      MenuActionType.check,
    ),
    ItemModel(
      '一键删除失效源',
      Icons.no_encryption,
      MenuActionType.delete_unavailable,
    ),
    ItemModel(
      '导出源',
      Icons.settings_overscan,
      MenuActionType.export,
    ),
  ];

  CustomPopupMenuController _controller = CustomPopupMenuController();

  Map<String, bool> __statusMap = {};

  handleClickSubMenu(MenuActionType action) async {
    switch (action) {
      case MenuActionType.check:
        XHttp.changeTimeout(connectTimeout: 1200, receiveTimeout: 1200);
        bool? checkCanDone = await showCupertinoDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            var refData = home.mirrorList;
            return MirrorCheckView(
              list: refData,
            );
          },
        );
        XHttp.changeTimeout();
        bool _checkCanDone = checkCanDone ?? false;
        if (_checkCanDone) {
          updateMirrorStatusMap();
        }
        break;
      case MenuActionType.delete_unavailable:
        bool status = await showDelUnavailableMirrorDialog();
        if (!status) return;
        List<String> result = MirrorManage.removeUnavailable(
          __statusMap,
        );
        setState(() {
          mirrorList.removeWhere((element) => result.contains(element.meta.id));
        });
        if (result.isNotEmpty) {
          home.updateMirrorIndex(0);
        }
        break;
      case MenuActionType.export:
        String append = MirrorManage.export(
          full: home.isNsfw,
        );

        DateTime today = new DateTime.now();
        String dateSlug =
            "${today.year.toString()}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}";

        String filename = "YY$dateSlug.json";
        if (GetPlatform.isIOS) {
          Directory directory = await getTemporaryDirectory();
          String path = '${directory.path}/$filename';
          File file = File(path);
          await file.writeAsString(append);
          Share.shareFilesWithResult([path]);
        } else if (GetPlatform.isDesktop) {
          Directory? directory = await getDownloadsDirectory();
          if (directory == null) return;
          String? path = await FilePicker.platform.saveFile(
            initialDirectory: directory.path,
            fileName: filename,
          );
          if (path == null) return;
          File file = File(path);
          file.existsSync();
          file.writeAsStringSync(append);
        }
        break;
    }
  }

  showDelUnavailableMirrorDialog() async {
    var completer = new Completer();
    showCupertinoDialog(
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('提示'),
        content: Text('确定要删除所有失效源吗？'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text(
              '取消',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
            onPressed: () {
              Get.back();
              completer.complete(false);
            },
          ),
          CupertinoDialogAction(
            child: const Text(
              '确定',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            isDestructiveAction: true,
            onPressed: () {
              Get.back();
              completer.complete(true);
            },
          )
        ],
      ),
      context: Get.context as BuildContext,
    );
    return completer.future;
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
                    _title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                CustomPopupMenu(
                  child: Container(
                    child: Icon(
                      CupertinoIcons.command,
                      size: 24,
                    ),
                    padding: EdgeInsets.all(12),
                  ),
                  menuBuilder: () => popMenuBox(
                    items: menuItems,
                    onTap: (MenuActionType value) {
                      _controller.hideMenu();
                      handleClickSubMenu(value);
                    },
                  ),
                  pressType: PressType.singleClick,
                  verticalMargin: -10,
                  controller: _controller,
                ),
              ],
            ),
            Divider()
          ],
        ),
      ),
      child: SafeArea(
        child: Scrollbar(
          controller: scrollController,
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
                    hashTable: __statusMap,
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
    required this.hashTable,
    this.onDel,
    this.minHeight = 42.0,
    this.maxHeight = 81.0,
  }) : super(key: key);

  final double minHeight;

  final double maxHeight;

  final MovieImpl item;

  final bool current;

  final SlidableActionCallback? onDel;

  final VoidCallback onTap;

  final Map<String, bool> hashTable;

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

  Widget get _logoDefaultImageWidget {
    return Image.asset(
      "assets/images/movie_default.png",
      width: 60,
      height: 42,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color _borderColor = Get.isDarkMode
        ? Colors.white.withOpacity(.1)
        : Colors.black.withOpacity(.1);

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
      child: Material(
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
                    color: _borderColor,
                  ),
                ),
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
                      return _logoDefaultImageWidget;
                    }
                    return CachedNetworkImage(
                      imageUrl: _logo,
                      fit: BoxFit.cover,
                      width: 60,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (
                        context,
                        url,
                        error,
                      ) =>
                          _logoDefaultImageWidget,
                    );
                  }),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            movieStatusWidget(
                              status: item.meta.status
                                  ? MovieStatusType.available
                                  : MovieStatusType.unavailable,
                              hash: item.meta.id,
                              hashTable: hashTable,
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
      ),
    );
  }
}

enum MovieStatusType {
  /// 可用
  available,

  /// 不可用
  unavailable,

  /// 未知
  unknown,
}

extension movieStatusTypeExtension on MovieStatusType {
  String get text {
    switch (this) {
      case MovieStatusType.available:
        return '可用';
      case MovieStatusType.unavailable:
        return '不可用';
      case MovieStatusType.unknown:
        return '未知';
      default:
        return '未知';
    }
  }
}

class movieStatusWidget extends StatelessWidget {
  const movieStatusWidget({
    Key? key,
    this.status = MovieStatusType.available,

    /// FIXME: 离谱, 为什么不直接传递 `bool` => [hashTable[hash]]
    /// 而是要整这种绝活??
    required this.hashTable,
    required this.hash,
  }) : super(key: key);

  final MovieStatusType status;
  final String hash;
  final Map<String, bool> hashTable;

  String get _text {
    return _type.text;
  }

  Color get _color {
    switch (_type) {
      case MovieStatusType.available:
        return Colors.pink;
      case MovieStatusType.unavailable:
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  MovieStatusType get _type {
    var cacheStatus = hashTable[hash];
    if (cacheStatus != null) {
      return cacheStatus
          ? MovieStatusType.available
          : MovieStatusType.unavailable;
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _color,
          ),
        ),
        SizedBox(
          width: 6,
        ),
        Container(
          child: Text(
            _text,
            style: TextStyle(
              color: _color,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class popMenuBox extends StatefulWidget {
  const popMenuBox({
    Key? key,
    required this.items,
    required this.onTap,
  }) : super(key: key);

  final List<ItemModel> items;

  final ValueChanged<MenuActionType> onTap;

  @override
  State<popMenuBox> createState() => _popMenuBoxState();
}

class _popMenuBoxState extends State<popMenuBox> {
  ItemModel? _hoverPopMenuItem;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color: const Color(0xFF4C4C4C),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.items
                .map(
                  (item) => InkWell(
                    onTap: () {
                      widget.onTap(item.action);
                    },
                    onHover: (isHover) {
                      _hoverPopMenuItem = isHover ? item : null;
                      setState(() {});
                    },
                    onTapDown: (_) {
                      _hoverPopMenuItem = item;
                      setState(() {});
                    },
                    onTapCancel: () {
                      _hoverPopMenuItem = null;
                      setState(() {});
                    },
                    child: Container(
                      height: 40,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: _hoverPopMenuItem?.title == item.title
                            ? Colors.blue
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            item.icon,
                            size: 15,
                            color: Colors.white,
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 10,
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
