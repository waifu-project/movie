import 'package:cached_network_image/cached_network_image.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:catmovie/shared/manage.dart';
import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'package:xi/xi.dart';

String kV1JSON =
    "https://cdn.jsdelivr.net/gh/waifu-project/v1@latest/yoyo.json";

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key, this.onNext});

  final VoidCallback? onNext;

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  bool isLoading = false;

  Future<void> withTap() async {
    if (isLoading) return;
    isLoading = true;
    setState(() {});
    List<MacCMSSpider> sources = [];
    try {
      sources = await SourceUtils.runTaks([kV1JSON]);
    } catch (e) {
      debugPrint(e.toString());
      EasyLoading.showError("获取源失败, 请重试");
    }
    isLoading = false;
    setState(() {});
    if (sources.isEmpty) {
      EasyLoading.showError("没有找到源, 请重试");
      return;
    }
    Get.back();
    SpiderManage.extend.addAll(sources);
    SpiderManage.saveToCache(SpiderManage.extend);
    EasyLoading.showSuccess("获取成功, 已添加${sources.length}个源!");
    widget.onNext?.call();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = context.mediaQuery.size.width >= 600;
    Widget child = SizedBox(
      width: double.infinity,
      height: context.mediaQuery.size.height * (isDesktop ? .96 : .72),
      child: CupertinoOnboarding(
        backgroundColor: Colors.transparent,
        bottomButtonChild: Zoom(
          child: Row(
            spacing: 6,
            children: [
              if (isLoading) CupertinoActivityIndicator(color: Colors.white),
              Text("初始化"),
            ],
          ),
        ),
        onPressedOnLastPage: withTap,
        pages: [
          WhatsNewPage(
            title: const Text("小猫影视"),
            featuresSeperator: const SizedBox(height: 24),
            titleToBodySpacing: 24,
            features: [
              WhatsNewFeature(
                icon: Icon(
                  CupertinoIcons.cursor_rays,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
                title: const Text('欢迎使用 🐈'),
                description: const Text(
                  '在开始使用之前先导入一些源吧\n(可能需要科学上网)',
                ),
              ),
              WhatsNewFeature(
                icon: Icon(
                  CupertinoIcons.gift,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
                title: const Text('内建苹果源支持 🌠'),
                description: const Text(
                  '我们精心挑选了目前最好的一些苹果源, 保证基本可用',
                ),
              ),
            ],
          ),
          CupertinoOnboardingPage(
            titleToBodySpacing: 18,
            title: Text('使用技巧'),
            body: DefaultTextStyle(
              style: TextStyle(
                fontSize: 16,
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 12,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("点击可切换首页源"),
                      CachedNetworkImage(
                        imageUrl:
                            "https://s2.loli.net/2025/09/17/UKtBJSdwfsc63aI.png",
                      ),
                      Text("长按播放单个选集可复制链接或投屏播放"),
                      CachedNetworkImage(
                        imageUrl:
                            "https://s2.loli.net/2025/09/17/t8OqBQPe9Db7Xnx.gif",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return child;
  }
}
