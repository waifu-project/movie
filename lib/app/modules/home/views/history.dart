import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/routes/app_pages.dart';
import 'package:catmovie/app/widget/helper.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:catmovie/isar/schema/video_search_schema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with AfterLayoutMixin {
  HomeController home = Get.find<HomeController>();

  List<VideoHistoryIsarModel> history = [];

  bool isEditing = false;

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    history = videoHistoryAs.filter().isNsfwEqualTo(home.isNsfw).findAllSync();
    setState(() {});
  }

  void handleDeleteHistoryByItem(VideoHistoryIsarModel item) {
    isarInstance.writeTxnSync(() {
      videoHistoryAs.deleteSync(item.id);
    });
    history.remove(item);
    EasyLoading.showToast(
      "删除成功(${item.ctx.title})",
      toastPosition: EasyLoadingToastPosition.bottom,
    );
    if (history.isEmpty) {
      isEditing = false;
    }
    setState(() {});
  }

  Future<void> handleDeleteAll() async {
    bool isNext = await showCupertinoDialog(
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('提示'),
        content: const Text("确定要删除所有历史记录吗?"),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              '取消',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text(
              '确定',
              style: TextStyle(color: Colors.blue),
            ),
          )
        ],
      ),
      context: context,
    );
    if (!isNext) return;
    isarInstance.writeTxnSync(() {
      videoHistoryAs.filter().isNsfwEqualTo(home.isNsfw).deleteAllSync();
    });
    history = [];
    isEditing = false;
    setState(() {});
  }

  Widget _buildWithEmptry() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          spacing: 24,
          children: [
            Image.asset(
              "assets/images/error.png",
              width: 120,
              height: 120,
            ),
            Text(
              "当前暂无历史记录",
              style: TextStyle(
                color: (context.isDarkMode ? '#6f737a' : '#767a82').$color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var textColor = context.isDarkMode ? Colors.white : Colors.black;
    return Scaffold(
      appBar: CupertinoEasyAppBar(
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Text(
                  "历史记录",
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
            ),
            Zoom(child: CupertinoNavigationBarBackButton()),
            if (history.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: Zoom(
                  child: IconButton(
                    onPressed: () {
                      isEditing = !isEditing;
                      setState(() {});
                    },
                    icon: Row(
                      spacing: 6,
                      children: [
                        if (!isEditing) ...[
                          Icon(CupertinoIcons.square_pencil, size: 20),
                          Text("管理", style: TextStyle(color: textColor)),
                        ] else ...[
                          Icon(CupertinoIcons.text_append, size: 20),
                          Text("完成", style: TextStyle(color: textColor)),
                        ],
                        SizedBox(width: 6),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Builder(builder: (context) {
                if (history.isEmpty) {
                  return _buildWithEmptry();
                }
                return SingleChildScrollView(
                  child: Column(
                    spacing: 24,
                    children: history.map((item) {
                      return SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Zoom(
                                onTap: () async {
                                  Get.dialog(
                                    Center(
                                      child: Image.asset(
                                        "assets/loading.gif",
                                        width: 120,
                                        height: 120,
                                      ),
                                    ),
                                  );
                                  var cx = home.mirrorList
                                      .firstWhereOrNull((mirror) {
                                    return mirror.meta.id == item.sid;
                                  });
                                  if (cx == null) {
                                    EasyLoading.showError("未找到源");
                                    return;
                                  }
                                  var data =
                                      await cx.getDetail(item.ctx.detailID);
                                  data.setContext(cx.meta);
                                  Get.back();
                                  Get.toNamed(
                                    Routes.PLAY,
                                    arguments: data,
                                  );
                                },
                                scaleRatio: .98,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 12,
                                  children: [
                                    Builder(builder: (context) {
                                      var img = item.ctx.cover;
                                      var w =
                                          context.mediaQuery.size.width * .32;
                                      var h =
                                          context.mediaQuery.size.height * .126;
                                      if (w >= 320) w = 320;
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: CachedNetworkImage(
                                          imageUrl: img,
                                          width: w,
                                          height: h,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey[200],
                                          ),
                                          errorWidget: (context, url, error) =>
                                              kErrorImage,
                                        ),
                                      );
                                    }),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 6,
                                        children: [
                                          Text(
                                            item.ctx.title,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontSize: 18, color: textColor),
                                          ),
                                          Opacity(
                                            opacity: .72,
                                            child: RichText(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              text: TextSpan(
                                                text: "上次看到 ",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: textColor),
                                                children: [
                                                  TextSpan(
                                                    text: item.ctx.pText,
                                                    style: TextStyle(
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color(0xFF6750A4)),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 3, horizontal: 6),
                                            child: Text(
                                              item.sourceName,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: textColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isEditing)
                              IconButton(
                                onPressed: () =>
                                    handleDeleteHistoryByItem(item),
                                icon: Icon(CupertinoIcons.delete),
                              )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ),
          ),
          AnimatedPositioned(
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 240),
            left: 0,
            bottom: isEditing ? 24 : -88,
            width: context.mediaQuery.size.width,
            child: Center(
              child: CupertinoButton.filled(
                sizeStyle: CupertinoButtonSize.small,
                mouseCursor: SystemMouseCursors.click,
                padding: EdgeInsets.symmetric(horizontal: 42),
                onPressed: handleDeleteAll,
                child: Text("一键清空"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
