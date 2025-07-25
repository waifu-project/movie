import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:xi/xi.dart';

const kUpdateUpstream =
    "https://api.github.com/repos/waifu-project/movie/releases";

class AutoUpdate extends StatefulWidget {
  const AutoUpdate({super.key});

  @override
  State<AutoUpdate> createState() => _AutoUpdateState();
}

class _AutoUpdateState extends State<AutoUpdate> with AfterLayoutMixin {
  GithubTag? tag;

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    var resp = await XHttp.dio.get<List<dynamic>>(
      kUpdateUpstream,
      options: $toDioOptions(CachePolicy.noCache),
    );
    var tags = (resp.data ?? []).map((item) {
      return GithubTag.fromJson(item as Map<String, dynamic>);
    }).toList();
    tag = tags[0];
    setState(() {});
  }

  Widget _buildChangelog() {
    if (tag == null) {
      return Expanded(
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
            child: Text(
              "# ${tag!.tag_name}",
              style: TextStyle(fontSize: 24),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                child: MarkdownWidget(data: tag!.body),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.mediaQuery.size.height * .72,
      child: Column(
        children: [
          _buildChangelog(),
          Zoom(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ).copyWith(
                bottom: context.mediaQuery.padding.bottom + 24,
              ),
              child: CupertinoButton.filled(
                sizeStyle: CupertinoButtonSize.medium,
                onPressed: () {
                  if (tag == null) return;
                  String url =
                      "https://github.com/waifu-project/movie/releases/latest/download/";
                  if (GetPlatform.isAndroid) {
                    url += "catmovie.apk";
                  } else if (GetPlatform.isIOS) {
                    url += "catmovie.ipa";
                  } else if (GetPlatform.isMacOS) {
                    url += "catmovie-mac.zip";
                  } else if (GetPlatform.isWindows) {
                    url += "catmovie-windows.zip";
                  } else if (GetPlatform.isLinux) {
                    url += "catmovie-linux-x86_64.tar.gz";
                  }
                  url.openURL();
                },
                onLongPress: () {
                  if (GetPlatform.isIOS) {
                    var url =
                        "apple-magnifier://install?url=https://github.com/waifu-project/movie/releases/latest/download/catmovie.ipa";
                    url.openURL();
                  }
                },
                child: Text("下载"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GithubTag {
  String tag_name;
  String body;

  GithubTag({
    required this.tag_name,
    required this.body,
  });

  factory GithubTag.fromJson(Map<String, dynamic> json) => GithubTag(
        tag_name: json["tag_name"],
        body: json["body"],
      );
}
