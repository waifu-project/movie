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

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/modules/home/views/home_config.dart';
import 'package:movie/utils/http.dart';
import 'package:video_player/video_player.dart';

class tvJsonData {
  String? name;
  String? url;

  tvJsonData({this.name, this.url});

  tvJsonData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['url'] = this.url;
    return data;
  }
}

class TvPageView extends StatefulWidget {
  const TvPageView({Key? key}) : super(key: key);

  @override
  _TvPageViewState createState() => _TvPageViewState();
}

class _TvPageViewState extends State<TvPageView> {
  HomeController home = Get.find();

  List<tvJsonData> tvLists = [];

  _loadTvData() async {
    List<tvJsonData> output = home.tvCacheLists;
    if (output.isEmpty) {
      var resp = await XHttp.dio.get(FeatchTvAPI);
      var data = resp.data as List<dynamic>;
      output = data.map((item) {
        Map<String, dynamic> _cache = Map.from(item);
        return tvJsonData.fromJson(_cache);
      }).toList();
      home.updateTvCacheLists(output);
    }
    setState(() {
      tvLists = output;
    });
  }

  Widget playerWidget = CupertinoActivityIndicator();

  List<VideoPlayerController> vControllers = [];
  List<ChewieController> cControllers = [];

  tvJsonData? nowTvJsonData;

  void _runInit() {
    var url = "";
    {
      var onceItem = home.currentTvItem;
      if (onceItem != null) {
        setState(() {
          nowTvJsonData = onceItem;
        });
        url = onceItem.url ?? "";
      }
    }
    var videoPlayController = VideoPlayerController.network(url);
    var chewieController = ChewieController(
      videoPlayerController: videoPlayController,
      aspectRatio: Get.width / (Get.height * .33),
      isLive: true,
      autoInitialize: true,
      autoPlay: true,
      customControls: CupertinoControls(
        backgroundColor: Colors.black38,
        iconColor: Colors.white,
      ),
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    vControllers.add(videoPlayController);
    cControllers.add(chewieController);
    setState(() {
      playerWidget = Chewie(
        controller: chewieController,
      );
    });
  }

  void _changeVideo(url) {
    vControllers.first.dispose();
    cControllers.first.dispose();
    vControllers.removeAt(0);
    cControllers.removeAt(0);
    var videoPlayController = VideoPlayerController.network(url);
    var chewieController = ChewieController(
      videoPlayerController: videoPlayController,
      aspectRatio: Get.width / (Get.height * .33),
      isLive: true,
      autoInitialize: true,
      autoPlay: true,
      customControls: CupertinoControls(
        backgroundColor: Colors.black38,
        iconColor: Colors.white,
      ),
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    vControllers.add(videoPlayController);
    cControllers.add(chewieController);
    setState(() {
      playerWidget = Chewie(
        controller: chewieController,
      );
    });
  }

  @override
  void initState() {
    _loadTvData();
    _runInit();
    _initTvScrollController();
    super.initState();
  }

  _initTvScrollController() {
    Future.delayed(Duration(milliseconds: 200), () {
      if (_tvScrollController.hasClients) {
        _tvScrollController.jumpTo(home.tvScrollControllerOffset);
      }
    });
    _tvScrollController.addListener(() {
      home.updateTvScrollControllerOffset(_tvScrollController.offset);
    });
  }

  @override
  dispose() {
    super.dispose();
    vControllers[0].dispose();
    cControllers[0].dispose();
    _tvScrollController.dispose();
  }

  String get appbarText {
    var result = "Live";
    if (nowTvJsonData == null) return result;
    var name = nowTvJsonData?.name ?? "";
    if (name.isEmpty) return name;
    return "$result: ${name}";
  }

  ScrollController _tvScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appbarText),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: 820,
        child: Column(
          children: [
            SizedBox(
              width: Get.width,
              height: Get.height * .33,
              child: playerWidget,
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _tvScrollController,
                      child: Column(
                        children: tvLists
                            .map(
                              (e) => tvCard(
                                item: e,
                                current: nowTvJsonData,
                                onTap: (url) {
                                  if (url == nowTvJsonData?.url) return;
                                  setState(() {
                                    nowTvJsonData = e;
                                  });
                                  home.updateCurrentTvItem(e);
                                  _changeVideo(url);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  kBarHeightWidget
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef UrlCallback = void Function(String url);

class tvCard extends StatelessWidget {
  final tvJsonData item;
  final UrlCallback onTap;

  final tvJsonData? current;

  tvJsonData get e => item;

  const tvCard({
    Key? key,
    required this.item,
    required this.onTap,
    this.current,
  }) : super(key: key);

  bool get isCurrent {
    return current?.url == item.url;
  }

  Color get _color {
    return !isCurrent ? Colors.black : Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 3),
            blurRadius: 12,
            spreadRadius: 0,
            color: Color.fromRGBO(211, 215, 219, 0.5),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            e.name ?? "",
            style: TextStyle(
              color: _color,
            ),
          ),
          TextButton(
            onPressed: () {
              var url = e.url;
              if (url == null) return;
              onTap(url);
            },
            child: Text("播放"),
          ),
        ],
      ),
    );
  }
}
