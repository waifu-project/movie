import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:movie/app/routes/app_pages.dart';
import 'package:movie/mirror/mirror_serialize.dart';

import '../controllers/play_controller.dart';

class PlayView extends GetView<PlayController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlayController>(
      builder: (play) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: CupertinoNavigationBarBackButton(),
          trailing: CupertinoButton(
            onPressed: () {},
            child: Icon(CupertinoIcons.share),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 2.7,
                child: Image.network(
                  play.movieItem.smallCoverImage ?? "",
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null)
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: child,
                      );
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.error),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                child: Text(
                  play.movieItem.title ?? "",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
              CupertinoButton(
                child: Text("播放"),
                onPressed: () {
                  switch (play.movieItem.videoType) {
                    case MirrorSerializeVideoType.iframe:
                      var __url = play.movieItem.videoUrl;
                      print(__url);
                      Get.toNamed(Routes.WEBVIEW, arguments: __url);
                      break;
                    default:
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
