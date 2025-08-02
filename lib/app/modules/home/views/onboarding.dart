import 'package:catmovie/app/widget/zoom.dart';
import 'package:catmovie/shared/manage.dart';
import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:xi/models/mac_cms/source_data.dart';
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
    List<SourceJsonData> realData = SourceUtils.mergeMirror(
      SpiderManage.extend,
      [],
      diff: false,
    );
    SpiderManage.mergeSpider(realData);
    EasyLoading.showSuccess("获取成功, 已添加${realData.length}个源!");
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
              Text("开始导入"),
            ],
          ),
        ),
        onPressedOnLastPage: withTap,
        pages: [
          WhatsNewPage(
            title: const Text("小猫影视"),
            featuresSeperator: const SizedBox(height: 12),
            features: [
              Text("欢迎使用小猫影视🐈"),
              Text("让我们在开始之前先导入一些源吧"),
              Row(
                spacing: 6,
                children: [
                  Text("在这之后, 请从"),
                  Text(
                    "设置->视频源帮助",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text("中手动更新源"),
                ],
              ),
              // WhatsNewFeature(
              //   icon: Icon(
              //     CupertinoIcons.mail,
              //     color: CupertinoColors.systemRed.resolveFrom(context),
              //   ),
              //   title: const Text('Found Events'),
              //   description: const Text(
              //     'TODO',
              //   ),
              // ),
            ],
          ),
          // const CupertinoOnboardingPage(
          //   title: Text('Support For Multiple Pages'),
          //   body: Icon(
          //     CupertinoIcons.square_stack_3d_down_right,
          //     size: 200,
          //   ),
          // ),
        ],
      ),
    );
    return child;
  }
}
