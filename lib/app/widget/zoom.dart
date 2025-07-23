import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';

class Zoom extends StatelessWidget {
  const Zoom({
    super.key,
    required this.child,
    this.onTap,
    this.scaleRatio = 0.965,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleRatio;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      hitTestBehavior: HitTestBehavior.translucent,
      child: BounceTapper(
        shrinkScaleFactor: scaleRatio,
        onTap: onTap,
        highlightColor: Colors.transparent,
        child: child,
      ),
    );
  }
}
