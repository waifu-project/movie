import 'dart:io';
import 'dart:ui';

import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_list_view/smooth_list_view.dart';

Map<String, DLNADevice> cacheDeviceList = {};

class CastScreen extends StatefulWidget {
  const CastScreen({
    super.key,
    required this.onTapDevice,
  });

  final ValueChanged<DLNADevice> onTapDevice;

  @override
  State<CastScreen> createState() => _CastScreenState();
}

class _CastScreenState extends State<CastScreen> {
  late DLNAManager searcher;
  late final DeviceManager m;
  Map<String, DLNADevice> deviceList = {};

  Future<void> init() async {
    m = await searcher.start(
      // Windows and Android do not support reusePort
      reusePort: !Platform.isWindows && !Platform.isAndroid,
    );
    m.devices.stream.listen((dlist) {
      dlist.forEach((key, value) {
        cacheDeviceList[key] = value;
      });
      setState(() {
        deviceList = cacheDeviceList;
      });
    });
    await _pullToRefresh();
  }

  Future _pullToRefresh() async {
    m.deviceList.forEach((key, value) {
      cacheDeviceList[key] = value;
    });
    setState(() {
      deviceList = cacheDeviceList;
    });
  }

  @override
  void initState() {
    super.initState();
    searcher = DLNAManager();
    init();
  }

  @override
  void dispose() {
    super.dispose();
    searcher.stop();
  }

  Widget buildItem(String uri, DLNADevice device) {
    var textColor = context.isDarkMode ? Colors.white : Colors.black;
    final title = device.info.friendlyName;
    final subtitle = '$uri\r\n${device.info.deviceType}';
    final s = subtitle.toLowerCase();
    var icon = Icons.wifi;
    final support = s.contains("mediarenderer") ||
        s.contains("avtransport") ||
        s.contains('mediaserver');
    if (!support) {
      icon = Icons.router;
    }
    final card = Zoom(
      scaleRatio: .98,
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: context.isDarkMode
                ? Colors.grey
                : Colors.grey.withValues(alpha: .12),
            width: .42,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: .24,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, bottom: 30),
              child: CircleAvatar(child: Icon(icon)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 16),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            subtitle,
                            softWrap: false,
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.onTapDevice(device);
        },
        child: card,
      ),
    );
  }

  Widget _body() {
    if (deviceList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final List<Widget> dlist = [];
    deviceList.forEach((uri, devi) {
      dlist.add(buildItem(uri, devi));
    });

    return SmoothListView(
      duration: kSmoothListViewDuration,
      children: dlist,
    );
  }

  @override
  Widget build(BuildContext context) {
    var textColor = context.isDarkMode ? Colors.white : Colors.black;
    return SizedBox(
      width: double.infinity,
      height: Get.height * .66,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 24,
              sigmaY: 24,
            ),
            child: SizedBox.shrink(),
          ),
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 12,
                      children: [
                        Icon(CupertinoIcons.tv_fill, color: textColor),
                        Text(
                          "投屏设备",
                          style: TextStyle(
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                Expanded(child: _body()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
