import 'package:cached_network_image/cached_network_image.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/widget/helper.dart';

class MovieCardItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String note;
  final VoidCallback onTap;

  const MovieCardItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Zoom(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Column(
            spacing: 9,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (context, url, progress) =>
                              DecoratedBox(
                            decoration: BoxDecoration(
                              color:
                                  (context.isDarkMode ? '#1c1c1e' : "#f0f0f0")
                                      .$color,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: progress.progress,
                              ),
                            ),
                          ),
                          errorWidget: (context, error, stackTrace) =>
                              kErrorImage,
                        ),
                      ),
                      if (note.isNotEmpty)
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 6, right: 6, left: 6),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Align(
                                  alignment: Alignment.bottomRight,
                                  child: UnconstrainedBox(
                                    alignment: Alignment.bottomRight,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: constraints.maxWidth * .88,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 3,
                                          horizontal: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: .72),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          note,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Text(
                  title,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
