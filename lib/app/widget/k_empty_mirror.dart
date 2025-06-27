import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';

class KEmptyMirror extends StatelessWidget {
  const KEmptyMirror({
    super.key,
    this.width,
    required this.cx,
    required this.context,
  });

  final double? width;
  final HomeController cx;
  final BuildContext context;

  double get _width {
    if (width == null) {
      return 120;
    }
    return width as double;
  }

  TextStyle get _style {
    return Theme.of(context)
        .textTheme
        .titleLarge!
        .copyWith(color: context.isDarkMode ? Colors.white : Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/error.png",
            fit: BoxFit.cover,
            width: _width,
          ),
          Text(
            '无数据源 :(',
            style: TextStyle(
              color: !context.isDarkMode ? Colors.black : Colors.white,
            ),
          ),
          GestureDetector(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                "设置 -> 视频源帮助",
                style: _style,
              ),
            ),
            onTap: () => cx.changeCurrentBarIndex(2 /*设置*/),
          ),
        ],
      ),
    );
  }
}
