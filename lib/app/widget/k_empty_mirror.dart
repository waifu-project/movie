import 'package:catmovie/app/extension.dart';
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
        .titleMedium!
        .copyWith(color: (context.isDarkMode ? Colors.white : Colors.black).withValues(alpha: .72));
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
              color: (context.isDarkMode ? '#6f737a' : '#767a82').$color,
            ),
          ),
          GestureDetector(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                // "设置 -> 视频源帮助",
                "设置 -> 视频源管理",
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
