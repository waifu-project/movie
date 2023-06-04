import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class kTitleBar extends StatelessWidget {
  final String title;

  const kTitleBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                height: 4,
                color: Colors.black,
                width: 82,
              ),
            ],
          ),
          const Row(
            children: [
              Text(
                "全部",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Icon(CupertinoIcons.arrow_right_circle),
            ],
          )
        ],
      ),
    );
  }
}
