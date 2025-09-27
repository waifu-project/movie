import 'dart:async';
import 'dart:io';

import 'package:catmovie/app/widget/zoom.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/widget/k_error_stack.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:catmovie/shared/manage.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:xi/xi.dart';

const kCatMovieSourceAPI =
    "https://cdn.jsdelivr.net/gh/waifu-project/v1@latest/x.json";

class SourceHelpTable extends StatefulWidget {
  const SourceHelpTable({super.key});

  @override
  createState() => _SourceHelpTableState();
}

class _SourceHelpTableState extends State<SourceHelpTable> {
  bool get showNSFW {
    return getSettingAsKeyIdent<bool>(SettingsAllKey.isNsfw);
  }

  final home = Get.find<HomeController>();

  Future<void> loadMirrorListApi() async {
    setState(() {
      _isLoadingFromAJAX = true;
    });
    try {
      var resp = await XHttp.dio.get(
        kCatMovieSourceAPI,
        options: $noCacheOption(),
      );
      late List<dynamic> list;
      if (resp.data is List) {
        list = resp.data;
      } else if (resp.data is Map<String, dynamic>) {
        var tmp = resp.data as Map<String, dynamic>;
        // 只要有这些 key 就都可以解析
        var keys = ["data", "list", "result", "items"];
        for (var key in keys) {
          if (tmp.containsKey(key)) {
            list = tmp[key];
            break;
          }
        }
      }
      List<AssetSourceItemJSONData> data = List.from(list).map((e) {
        return AssetSourceItemJSONData.fromJson(e as Map<String, dynamic>);
      }).toList();
      if (!showNSFW) {
        data = data.where((element) {
          return !(element.nsfw ?? true);
        }).toList();
      }
      setState(() {
        mirrors = data;
        _isLoadingFromAJAX = false;
        _loadingErrorStack = "";
      });
    } catch (e) {
      setState(() {
        _isLoadingFromAJAX = false;
        _loadingErrorStack = e.toString();
      });
    }
  }

  bool _isLoadingFromAJAX = false;

  String _loadingErrorStack = "";

  List<AssetSourceItemJSONData> mirrors = [];

  @override
  void initState() {
    super.initState();
    loadMirrorListApi();
  }

  String get playfulConfirmText {
    return "我知道了";
  }

  Future<void> handleCopyText(
      {AssetSourceItemJSONData? item, bool canCopyAll = false}) async {
    List<AssetSourceItemJSONData> actions = mirrors;
    if (!canCopyAll && item != null) actions = [item];
    var ctx = Get.context;
    if (ctx == null) return;
    await Future.forEach(actions, (AssetSourceItemJSONData element) {
      var msg = element.msg ?? "";
      Completer completer = Completer();
      if (msg.isEmpty) {
        completer.complete();
        return completer.future;
      }
      showEasyCupertinoDialog(
        content: Text(element.msg ?? ""),
        title: element.title,
        confirmText: playfulConfirmText,
        onDone: () {
          Get.back();
          completer.complete();
        },
      );
      return completer.future;
    });

    List<String> result = [];
    if (canCopyAll) {
      for (var element in actions) {
        var cx = element.url ?? "";
        if (cx.isNotEmpty) {
          result.add(cx);
        }
      }
    } else {
      var cx = actions[0].url ?? "";
      if (cx.isNotEmpty) {
        result.add(cx);
      }
    }
    if (result.isEmpty /* 内容为空 */) return;
    updateExtendMirrorList(result);
    showEasyCupertinoDialog(
      content: '已添加到本地(=^-ω-^=)! \n请到 设置->视频源管理 中手动获取配置(源)',
    );
  }

  void updateExtendMirrorList(List<String> result) {
    var old =
        getSettingAsKeyIdent<String>(SettingsAllKey.mirrorTextarea).trim();
    var lines = old.split('\n').where((element) {
      var cx = element.trim();
      return cx.isNotEmpty;
    }).toList();
    for (var element in result) {
      // 这里要去重
      if (!lines.contains(element)) {
        lines.add(element);
      }
    }
    var ext = lines.join("\n");
    updateSetting(SettingsAllKey.mirrorTextarea, ext);
  }

  String get _wrapperAjaxStatusLable {
    if (!_isLoadingFromAJAX) return "啥也没有";
    return "加载网络资源中";
  }

  /// 判断加载失败
  bool get _canLoadFail {
    return _loadingErrorStack.isNotEmpty && !_isLoadingFromAJAX;
  }

  /// 导入文件
  Future<void> handleImportFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'json',
        'txt',
      ],
    );

    if (result == null) {
      showEasyCupertinoDialog(
        content: "未选择文件 :(",
        confirmText: playfulConfirmText,
      );
      return;
    }
    List<File> files = result.paths.map((path) => File(path!)).toList();

    // ==========================
    var sourceKey = "source";
    var filenameKey = "filename";
    // ==========================

    var data = files
        .where((e) => !isBinaryAsFile(e))
        .toList()
        .map<Map<String, dynamic>>((item) {
          String filename = item.uri.pathSegments.last;
          return {
            sourceKey: item.readAsStringSync(),
            filenameKey: filename,
          };
        })
        .toList()
        .where((e) => verifyStringIsJSON(e[sourceKey] as String))
        .toList();
    if (data.isEmpty) {
      showEasyCupertinoDialog(
        content: "导入的文件格式错误 :(",
        confirmText: playfulConfirmText,
      );
      return;
    }
    var collData = <String, List<ISpiderAdapter>>{};
    for (var item in data) {
      String source = item[sourceKey] as String;
      String filename = item[filenameKey] as String;
      var easyParseData = SourceUtils.tryParseDynamic(source);
      if (easyParseData == null) continue;
      List<ISpiderAdapter> result = [];
      if (easyParseData is ISpiderAdapter) {
        result = [easyParseData];
      } else if (easyParseData is List) {
        var append = easyParseData
            .where((element) {
              return element != null;
            })
            .toList()
            .map((ele) {
              return ele as ISpiderAdapter;
            });
        result.addAll(append);
      }
      collData[filename] = result;
    }

    String easyMessage = "";
    List<ISpiderAdapter> stack = [];

    collData.forEach((k, v) async {
      int len = v.length;
      if (v.isNotEmpty) {
        stack.addAll(v);
        easyMessage += "$k中有$len个源\n";
      }
    });
    if (stack.isEmpty) {
      showEasyCupertinoDialog(
        content: "未导入源, 可能是JSON文件格式不对? :(",
        confirmText: playfulConfirmText,
      );
      return;
    } else {
      // 合并新源到现有源列表
      int oldLength = SpiderManage.extend.length;

      // 去重：移除已存在的源
      for (var newSource in stack) {
        bool exists = SpiderManage.extend
            .any((existing) => existing.meta.api == newSource.meta.api);
        if (!exists) {
          SpiderManage.extend.add(newSource);
        }
      }

      int diff = SpiderManage.extend.length - oldLength;
      if (diff > 0) {
        SpiderManage.saveToCache(SpiderManage.extend);
      }

      var diffMsg = "本次共合并$diff个源!";
      if (diff <= 0) {
        diffMsg = "本次未合并!没有新的源!";
      }
      easyMessage += '\n$diffMsg';
      showEasyCupertinoDialog(
        content: Column(
          spacing: 24,
          children: [
            const Icon(
              CupertinoIcons.hand_thumbsup,
              size: 51,
              color: CupertinoColors.systemBlue,
            ),
            Text(easyMessage),
          ],
        ),
        confirmText: "好耶ヾ(✿ﾟ▽ﾟ)ノ",
      );
    }
  }

  Widget get _errorWidget {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "// 需要科学上网",
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              decorationColor: CupertinoColors.systemPink,
              color: CupertinoColors.systemPink,
              fontSize: 18,
            ),
          ),
          KErrorStack(
            msg: _loadingErrorStack,
          ),
        ],
      ),
    );
  }

  Widget get _mirrorEmptyStateWidget {
    return Center(
      child: Column(
        spacing: 24,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Builder(builder: (context) {
            if (_isLoadingFromAJAX) {
              return const CircularProgressIndicator();
            }
            return const Icon(CupertinoIcons.zzz);
          }),
          Text(
            _wrapperAjaxStatusLable,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: context.isDarkMode ? Colors.white : Colors.black),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoEasyAppBar(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Zoom(child: const CupertinoNavigationBarBackButton()),
                  Text(
                    "o(-`д´- ｡)",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 12,
                    ),
                    child: Zoom(
                      child: CupertinoButton.filled(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        onPressed: handleImportFiles,
                        child: Row(
                          spacing: 3,
                          children: [
                            const Icon(
                              CupertinoIcons.arrow_down_square_fill,
                              color: CupertinoColors.white,
                            ),
                            Text(
                              "导入文件",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.copyWith(
                                    color: CupertinoColors.white,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider()
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: CupertinoScrollbar(
                  child: Builder(
                    builder: (context) {
                      if (mirrors.isEmpty) {
                        if (_canLoadFail) {
                          return _errorWidget;
                        }
                        return _mirrorEmptyStateWidget;
                      }
                      return SmoothListView(
                        duration: kSmoothListViewDuration,
                        children: mirrors.map((item) {
                          return Zoom(
                            scaleRatio: .99,
                            child: CupertinoListTile(
                              title: Text(
                                item.title ?? "",
                                style: TextStyle(
                                  color: context.isDarkMode
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                handleCopyText(item: item);
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
              Builder(
                builder: (context) {
                  if (mirrors.isEmpty) {
                    if (_canLoadFail) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 24,
                        ),
                        child: CupertinoButton.filled(
                          padding: const EdgeInsets.all(12),
                          child: const Text("重新加载"),
                          onPressed: () {
                            loadMirrorListApi();
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }
                  return Zoom(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 12,
                      ),
                      child: CupertinoButton.filled(
                        borderRadius: BorderRadius.circular(24),
                        child: const Text("一键添加到本地"),
                        onPressed: () {
                          handleCopyText(canCopyAll: true);
                        },
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

void showEasyCupertinoDialog({
  String? title,
  dynamic content,
  VoidCallback? onDone,
  BuildContext? context,
  String? confirmText,
}) {
  Widget child = const SizedBox.shrink();
  String outputTitle = title ?? "提示";
  String outputConfrimText = confirmText ?? "确定";
  if (content is Widget) {
    child = content;
  } else if (content is String) {
    child = Text(content);
  }
  var ctx = Get.context as BuildContext;
  if (context != null) ctx = context;
  showCupertinoDialog(
    builder: (BuildContext context) => EasyShowModalWidget(
      content: child,
      title: outputTitle,
      onDone: onDone,
      confirmText: outputConfrimText,
    ),
    context: ctx,
  );
}

class EasyShowModalWidget extends StatelessWidget {
  const EasyShowModalWidget({
    super.key,
    this.onDone,
    required this.content,
    this.title = "提示",
    this.confirmText = "确定",
    this.confirmTextColor = Colors.red,
  });

  final VoidCallback? onDone;
  final String title;
  final Widget content;
  final String confirmText;
  final Color confirmTextColor;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Column(
        children: [
          Text(title),
        ],
      ),
      content: content,
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          child: Text(
            confirmText,
            style: TextStyle(
              color: confirmTextColor,
            ),
          ),
          onPressed: () {
            if (onDone != null) {
              onDone!();
            } else {
              Get.back();
            }
          },
        ),
      ],
    );
  }
}
