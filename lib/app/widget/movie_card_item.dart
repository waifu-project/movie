import 'package:cached_network_image/cached_network_image.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/widget/helper.dart';

class MovieCardItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onTap;

  const MovieCardItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, progress) => Center(
                      child: CircularProgressIndicator(
                        value: progress.progress,
                      ),
                    ),
                    errorWidget: (context, error, stackTrace) => kErrorImage,
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
