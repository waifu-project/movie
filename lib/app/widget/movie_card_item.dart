import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie/app/widget/helper.dart';

class MovieCardItem extends StatefulWidget {
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
  createState() => _MovieCardItemState();
}

class _MovieCardItemState extends State<MovieCardItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      mouseCursor: SystemMouseCursors.click,
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
                  imageUrl: widget.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.fill,
                  progressIndicatorBuilder: (context, url, progress) => Center(
                    child: CircularProgressIndicator(
                      value: progress.progress,
                    ),
                  ),
                  errorWidget: (context, error, stackTrace) => kErrorImage,
                ),
              ),
            ),
            Text(
              widget.title,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
