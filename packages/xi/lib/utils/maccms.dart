import '../adapters/mac_cms.dart';
import '../interface.dart';
import 'helper.dart';

/// 将 [VideoInfo] 转换为 [Videos]
/// 单个 [VideoInfo] 格式参考:
/// - name: 源分类集合
/// - url: 多个视频播放地址, 通过 `.split("#").split("$")`
///        > 其中 [0] 为名称, [1] 为视频地址
List<Videos> videoInfo2RealVideos(List<VideoInfo> cx) {
  List<Videos> result = [];
  for (var element in cx) {
    var url = element.url;
    var hasUrl = isURL(url);
    if (hasUrl) {
      var output = [element];
      result.add(Videos(title: element.name, datas: []));
      var urls = url.split("#");
      if (urls.length >= 2) {
        output = urls
            .map(
              (e) => VideoInfo(
                url: e,
                type: MacCMSSpider.easyGetVideoType(e),
              ),
            )
            .toList();
      }
      result.last.datas.addAll(output);
    } else {
      var movies = url.split("#");
      var cache = Videos(title: element.name, datas: []);
      for (var e in movies) {
        var subItem = e.split("\$");
        if (subItem.length <= 1) continue;
        var title = subItem[0];
        var url = subItem[1];
        // var subType = subItem[2];
        cache.datas.add(VideoInfo(
          name: title,
          url: url,
          type: MacCMSSpider.easyGetVideoType(url),
        ));
      }
      result.add(cache);
    }
  }
  result = result.where((element) {
    return element.datas.isNotEmpty;
  }).toList();
  return result;
}
