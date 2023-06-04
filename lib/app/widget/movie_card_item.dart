import 'package:flutter/material.dart';

import 'helper.dart';

class MovieCardItem extends StatefulWidget {
  final String imageUrl;

  final String title;

  final VoidCallback onTap;

  const MovieCardItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  _MovieCardItemState createState() => _MovieCardItemState();
}

class _MovieCardItemState extends State<MovieCardItem> {
  final double _radiusSize = 8.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        // tip: 不设置高度
        // height: 120,
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                widget.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_radiusSize),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(.2),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(_radiusSize),
                        child: child,
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) => ClipRRect(
                  borderRadius: BorderRadius.circular(_radiusSize),
                  child: KCoverImage,
                ),
              ),
            ),
            const SizedBox(
              height: 9,
            ),
            Container(
              child: Text(
                widget.title,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
