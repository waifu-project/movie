import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie/app/shared/mirror_status_stack.dart';
import 'package:movie/impl/movie.dart';

enum MirrorTabButtonStatus {
  /// 取消
  cancel,

  /// 确定
  done,
}

class MirrorCheckView extends StatefulWidget {
  const MirrorCheckView({
    Key? key,
    required this.list,
  }) : super(key: key);

  final List<MovieImpl> list;

  @override
  State<MirrorCheckView> createState() => _MirrorCheckViewState();
}

class _MirrorCheckViewState extends State<MirrorCheckView> {
  double get _checkBoxWidth {
    var w = Get.width;
    if (w >= 900) return 320;
    return w * .6;
  }

  double get _checkBoxHeight {
    var h = Get.height;
    if (h >= 900) return 420;
    return h * .48;
  }

  bool running = false;

  List<MovieImpl> get listStack => widget.list;

  int get listStackLen => listStack.length;

  runTasks() async {
    while (_taskCount < listStackLen && running) {
      var curr = listStack[_taskCount];
      if (_taskCount == listStackLen - 1) {
        running = false;
        setState(() {});
      }
      var name = curr.meta.name;
      updateCurrentStatusText("开始测试 $name");
      bool isSuccess = false;
      try {
        await curr.getHome();
        // debugPrint("本次请求成功");
        // updateCurrentStatusText("测试成功 $name");
        isSuccess = true;
        setState(() {
          _success++;
        });
      } catch (e) {
        // debugPrint("本次请求错误");
        // updateCurrentStatusText("测试失败 $name");
        isSuccess = false;
        setState(() {
          _fail++;
        });
      }
      String id = curr.meta.id;
      MirrorStatusStack().pushStatus(id, isSuccess);
      setState(() {
        _taskCount++;
      });
    }
  }

  /// 成功
  int _success = 0;

  /// 失败
  int _fail = 0;

  /// 当前执行任务数
  int _taskCount = 0;

  String get _taskText {
    return "任务: $_taskCount/$listStackLen";
  }

  String get _text {
    return "成功: $_success, 失败: $_fail";
  }

  beforeHook() {
    running = true;
    setState(() {});
    runTasks();
  }

  bool get easyDone {
    return _taskCount == listStackLen && !running;
  }

  @override
  void initState() {
    super.initState();

    beforeHook();
  }

  @override
  void dispose() {
    super.dispose();
  }

  handleClickMenu(MirrorTabButtonStatus action) {
    switch (action) {
      case MirrorTabButtonStatus.cancel:
        running = false;
        // MirrorStatusStack().clean();
        debugPrint("已取消 >_<");
        setState(() {});
        Get.back(
          result: false,
        );
        break;
      case MirrorTabButtonStatus.done:
        MirrorStatusStack().flash();
        Get.back(
          result: true,
        );
        break;
    }
  }

  String _currentStatusText = "";

  updateCurrentStatusText(String text) {
    _currentStatusText = text;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Get.isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          width: _checkBoxWidth,
          height: _checkBoxHeight,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                "获取源状态",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 6,
              ),
              const Divider(
                thickness: 2,
              ),
              Expanded(
                child: Column(
                  children: [
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      child: Expanded(
                        child: Column(
                          children: [
                            Text(
                              _taskText,
                            ),
                            Text(
                              _text,
                            )
                          ],
                        ),
                      ),
                    ),
                    Builder(builder: (context) {
                      if (easyDone) {
                        return const Icon(
                          CupertinoIcons.archivebox,
                          size: 66,
                        );
                      }
                      return const CircularProgressIndicator();
                    }),
                    Builder(builder: (context) {
                      if (easyDone) return const SizedBox.shrink();
                      Color bgColor = Colors.white;
                      if (!Get.isDarkMode) {
                        bgColor = Colors.black;
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor.withOpacity(.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _currentStatusText,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),
                    if (!easyDone)
                      const SizedBox(
                        height: 12,
                      ),
                    Builder(builder: (context) {
                      var text = "执行任务中";
                      if (easyDone) {
                        text = "任务已完成";
                      }
                      var child = Text(text);
                      if (easyDone) return Expanded(child: child);
                      return child;
                    }),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              if (!easyDone)
                CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Builder(builder: (context) {
                    String _text = "暂停任务";
                    if (!running) {
                      _text = "继续任务";
                    }
                    return Text(_text);
                  }),
                  onPressed: () {
                    running = !running;
                    setState(() {});
                    if (running) {
                      if (_taskCount != 0) {
                        _taskCount--;
                        setState(() {});
                      }
                      runTasks();
                    }
                  },
                ),
              const SizedBox(
                height: 8,
              ),
              const Divider(
                thickness: 1,
                height: 0,
              ),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text("取消"),
                        onPressed: () {
                          handleClickMenu(
                            MirrorTabButtonStatus.cancel,
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 1,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text("确定"),
                        onPressed: () {
                          handleClickMenu(
                            MirrorTabButtonStatus.done,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
