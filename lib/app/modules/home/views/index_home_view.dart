import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/app/modules/home/views/home_config.dart';
import 'package:movie/app/routes/app_pages.dart';
import 'package:movie/app/widget/k_title_bar.dart';
import 'package:movie/app/widget/movie_card_item.dart';

class IndexHomeView extends GetView {
  final homeview = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    if (homeview.isLoading) {
      return Center(child: CupertinoActivityIndicator());
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          ...homeview.homedata
              .map((item) => Column(
                    children: [
                      kTitleBar(
                        title: item.cardTitle,
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        controller: new ScrollController(
                          keepScrollOffset: false,
                        ),
                        crossAxisCount: 3,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 12,
                        childAspectRatio:
                            (MediaQuery.of(context).size.width / 3) /
                                (MediaQuery.of(context).size.height / 4),
                        padding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                        children: [
                          ...item.cards
                              .map(
                                (subItem) => MovieCardItem(
                                  imageUrl: subItem.smallCoverImage ?? "",
                                  title: subItem.title ?? "",
                                  onTap: () {
                                    Get.toNamed(Routes.PLAY, arguments: subItem);
                                  },
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ],
                  ))
              .toList(),
          kBarHeightWidget,
        ],
      ),
    );
  }
}
