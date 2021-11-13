import 'package:flutter/cupertino.dart';
import 'package:movie/app/modules/home/views/home_config.dart';

class KBody extends StatelessWidget {
  
  final Widget child;

  const KBody({ Key? key, required this.child }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: child),
        kBarHeightWidget,
      ],
    );
  }
}