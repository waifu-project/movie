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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/routes/app_pages.dart';
import 'package:movie/app/widget/k_body.dart';
import 'package:movie/app/widget/k_empty_mirror.dart';
import 'package:movie/app/widget/k_error_stack.dart';
import 'package:movie/app/widget/movie_card_item.dart';
import 'package:movie/app/widget/window_appbar.dart';
import 'package:movie/config.dart';
import 'package:movie/mirror/mirror_serialize.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class IndexHomeView extends StatefulWidget {
  const IndexHomeView({Key? key}) : super(key: key);

  @override
  _IndexHomeViewState createState() => _IndexHomeViewState();
}

class _IndexHomeViewState extends State<IndexHomeView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return IndexHomeViewPage();
  }

  @override
  bool get wantKeepAlive => true;
}

class IndexHomeViewPage extends GetView {
  final HomeController home = Get.find();

  int get cardCount {
    bool isLandscape = Get.context!.isLandscape;
    if (GetPlatform.isMobile && !isLandscape) return 3;
    var w = home.windowLastSize.width;
    if (w >= 1000) return 5;
    return 3;
  }

  // double get childAspectRatio {
  //   var val = home.windowLastSize.aspectRatio;
  //   if (GetPlatform.isDesktop) return val;
  //   return val * 1.2;
  // }

  /// 错误日志
  String get errorMsg => home.indexHomeLoadDataErrorMessage;

  /// 错误日志最大展示行数
  int get errorMsgMaxLines => 12;

  handleClickItem(MirrorOnceItemSerialize subItem) async {
    var data = subItem;
    if (subItem.videos.isEmpty) {
      var id = subItem.id;
      var _textStyle = Theme.of(Get.context as BuildContext).textTheme.bodyText2!.copyWith(
        color: CupertinoColors.systemBlue,
      );
      Get.dialog(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: CupertinoColors.systemBlue,
              ),
              SizedBox(height: 12,),
              Text(
                "加载中",
                style: _textStyle,
              ),
            ],
          ),
        ),
        barrierColor: CupertinoColors.inactiveGray.withOpacity(.9),
      );
      data = await home.currentMirrorItem.getDetail(
        id,
      );
      Get.back();
    }
    Get.toNamed(
      Routes.PLAY,
      arguments: data,
    );
  }

  /// 每个卡片的高度
  /// 用设备高度 * 0.33
  /// 横屏情况下 * 0.42
  double get _cardOnceHeight {
    double scan = .27;
    if (cardCount >= 5) scan = .42;
    return Get.height * scan;
  }

  double get _calcImageWidth {
    var width = home.windowLastSize.width;
    // 桌面平台
    if (width >= 500) return 120;
    return width * .6;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeview) => Scaffold(
        appBar: WindowAppBar(
          iosBackStyle: true,
          title: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 9,
            ),
            child: Text(
              APP_TITLE,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          actions: [
            if (!home.mirrorListIsEmpty)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: CupertinoButton(
                  child: Icon(
                    Icons.movie,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    homeview.showMirrorModel(context);
                  },
                ),
              ),
          ],
        ),
        body: KBody(
          child: Builder(builder: (context) {
            if (home.mirrorListIsEmpty) {
              return KEmptyMirror(
                width: _calcImageWidth,
              );
            }
            return SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: WaterDropHeader(
                refresh: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoActivityIndicator(),
                    SizedBox(
                      width: 12,
                    ),
                    Text("加载中"),
                  ],
                ),
                complete: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.smiley),
                    SizedBox(
                      width: 12,
                    ),
                    Text("加载完成"),
                  ],
                ),
              ),
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus? mode) {
                  Widget body;
                  if (mode == LoadStatus.idle) {
                    body = Text("上划加载更多");
                  } else if (mode == LoadStatus.loading) {
                    body = CupertinoActivityIndicator();
                  } else if (mode == LoadStatus.failed) {
                    body = Text("加载失败, 请重试");
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text("释放以加载更多");
                  } else {
                    body = Text("没有更多数据");
                  }
                  return Center(
                    child: body,
                  );
                },
              ),
              controller: homeview.refreshController,
              onLoading: homeview.refreshOnLoading,
              onRefresh: homeview.refreshOnRefresh,
              child: Builder(
                builder: (_) {
                  if (homeview.isLoading) {
                    return Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }

                  if (homeview.homedata.isEmpty) {
                    return Container(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/empty.png",
                                fit: BoxFit.cover,
                                width: Get.width * .8,
                                height: Get.height * .4,
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              CupertinoButton.filled(
                                child: Text("重新加载"),
                                onPressed: () {
                                  homeview.updateHomeData(isFirst: true);
                                },
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              KErrorStack(
                                msg: errorMsg,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return WaterfallFlow.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cardCount,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                    ),
                    itemCount: homeview.homedata.length,
                    itemBuilder: (BuildContext context, int index) {
                      var subItem = homeview.homedata[index];
                      var _h = index % 2 == 0
                          ? _cardOnceHeight
                          : (_cardOnceHeight * .8);
                      return Container(
                        height: _h,
                        child: MovieCardItem(
                          imageUrl: subItem.smallCoverImage,
                          title: subItem.title,
                          onTap: () {
                            handleClickItem(subItem);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
