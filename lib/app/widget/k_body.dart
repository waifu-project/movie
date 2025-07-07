import 'package:flutter/cupertino.dart';

class KBody extends StatelessWidget {
  final Widget child;

  const KBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        horizontal: 12
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child),
          const SizedBox(height: 63),
        ],
      ),
    );
  }
}
