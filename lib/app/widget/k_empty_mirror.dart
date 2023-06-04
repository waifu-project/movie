import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KEmptyMirror extends StatelessWidget {
  const KEmptyMirror({
    Key? key,
    this.width,
  }) : super(key: key);

  final double? width;

  double get _width {
    if (width == null) {
      return 120;
    }
    return width as double;
  }

  TextStyle get _style {
    var ctx = Get.context as BuildContext;
    return Theme.of(ctx)
        .textTheme
        .titleLarge!
        .copyWith(color: Theme.of(ctx).indicatorColor);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/error.png",
            fit: BoxFit.cover,
            width: _width,
          ),
          const SizedBox(
            height: 12,
          ),
          const Text('无数据源 :('),
          const SizedBox(
            height: 12,
          ),
          Text(
            "设置 -> 视频源帮助",
            style: _style,
          ),
        ],
      ),
    );
  }
}
