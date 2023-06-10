import 'dart:io';

import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/io.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:movie/utils/path.dart';

/// dio http 请求库缓存时间
///
/// FIXME: `detail/search` 这种接口不能缓存👀
const kHttpCacheTime = Duration(hours: 2);

/// 默认所有的 `dio-http` 请求都持久化话([kHttpCacheTime])
///
/// 此扩展可以修改 `options` 控制缓存行为
///
/// 参考: https://pub.dev/packages/dio_cache_interceptor
///
/// ```dart
/// var resp = await XHttp.dio.get(
///  fetchMirrorAPI,
///  options: $toDioOptions(CachePolicy.noCache),
/// );
///```
extension AnyInjectHttpCacheOptions on Object {
  Options $toDioOptions(CachePolicy? cachePolicy) {
    var options = kHttpCacheMiddlewareOptions
        .copyWith(policy: CachePolicy.noCache)
        .toOptions();
    return options;
  }
}

var kHttpCacheMiddlewareOptions = CacheOptions(
  store: MemCacheStore(),
  policy: CachePolicy.forceCache,
  hitCacheOnErrorExcept: [401, 403],
  maxStale: kHttpCacheTime,
  priority: CachePriority.normal,
  cipher: null,
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  allowPostMethod: true,
);

class XHttp {
  XHttp._internal();

  /// 网络请求配置
  static final Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 13),
  ));

  static changeTimeout({
    int connectTimeout = 15,
    int receiveTimeout = 13,
  }) {
    dio.options.connectTimeout = Duration(seconds: connectTimeout);
    dio.options.receiveTimeout = Duration(seconds: receiveTimeout);
  }

  /// 初始化dio
  static Future<void> init() async {
    /// 初始化cookie
    var value = await PathUtils.getDocumentsDirPath();
    var cookieJar = PersistCookieJar(
      storage: FileStorage(value + "/.cookies/"),
    );
    dio.interceptors.add(CookieManager(cookieJar));

    dio.interceptors
        .add(DioCacheInterceptor(options: kHttpCacheMiddlewareOptions));

    /// https://pub.dev/packages/awesome_dio_interceptor
    if (kDebugMode) {
      dio.interceptors.add(
        AwesomeDioInterceptor(
          logRequestTimeout: false,
          logRequestHeaders: false,
          logResponseHeaders: false,
          logger: debugPrint,
        ),
      );
    }

    /*
    ---------------------------------------------------------------------证书啥的, 都是访问的盗版资源, 无所谓
    BJYY?PGBBBGGGGGGGGGGPP5555PPPP5PP5YYYYYJJJJJJJJYY5PB###BGBB#BYJP5PYGGGBBBBGPPGBGPGPPP&#GPPGBB&BBBPBB
    #YYY!JYYBBBBBBBGGGGGPPPGPPP55YYJJ?77!~~~~~~~~!!!!!7?YGB#BPGBGPGBBBGB#BBB##BBBB#################B###B
    B7PP7JG!5PPPPP555PGGGGBG55JJJ?7!~^..:::::^^^~~~~~~!!7?JPBGPPPPPPPPPPPPPPPPGGGGGGGGGGGGGGGGGGGGGGGGBG
    #P555PG55555555YYPBBBGPJJ??77~^:.. .....::^^^^~~~~~!!77?5GGP5GGB###################BBB##BBBBBBBBBBBG
    BPGGGGGGGGGGGGBBBBBBPJ!777!7~^:..    ....:^^^^^~~~~!!!77J5PG55GGBGGGGGGGPGPPGBG55555555555555555555Y
    PJJJJJJJJJJJJJGBBGGY!~!!7~7^::. ... .....::^^^^^~~~~!!77?J5PP5PGBGBP55555555PGY??7??????????????????
    Y~~!!!!!!!!!!5BBG57~~7!7~~^^.   ..   ......:^^^~~~~~!!7??J5PPPGG#BBB555555555PY7?77???????77????????
    Y~!!!!!!!!!!5BGG57~!!~~~^^.. ...:.  ..:.::^~~!!!!!!!!7??JY5GGBB#####G55555555PY777777777777777777777
    Y~!!!!!!!!!YBBBP?7?7!!777!!~^^^~^:::^~~!7JJJYYJJ???????JJY5GB######&#G5555555PY777777777!!7777777777
    Y~!!~!!!!!?BBGBY????7????7777!!7!~~~!77?JJJJJJJ????JJJJJYY5PB##&&#&&&#P555555PY!!777!77!!7777!777777
    Y~~!~~~!!!5BBGP??7!!~~^:^~!777?7~~!7????!~^:::^~!!7?YYYYYY55B##&&&&&&&G555555P5!!77!!!7777!!77777777
    Y~~!~~~~!!5GGG5?7!~^^^^^!?JJJ?7!~~~7?JJ777???777777?JY55YYY5B#&&&&&&&&G555555P57!77!77!777!!77777777
    Y~!!~~~~!!YGPGJ77??JYY5PPPGPP5J!^::~7?JJY55Y5PPPGPP55Y5YJYYPGB#&&&&&&#P555555P57!77!7!!!!7!!!7777777
    Y~!!~~~~~~JPP57YPPPPPPP55PP55YJ~^..^~!!!7?77777??JY55YJ?JYY5GB#&&&&&&BP555555P577!77777777!7!!777777
    Y~!!~~~~~~?5PJ!!!7?JJJYYYYJ7!!~^:..^~!!~~!7?JYYYYYJ7~!!7??J5PB#&&&&&#G5555555P5777777777777!7777777!
    Y~~~~~~~~~JP5!~~^^^^^!77!~^~~~~^^..^~!!!~^^^^^~~~^^^~!!7777YPG######BP5555555P57!777777!77!!7777777!
    J~~~~~~~~~?PY!~^^::......:^~~~~^:.:~~!77!!~^::..::^^~~!77??YPB###&#G555555555PP?7!!777!!777!77777777
    J~~~~~~~~~!YY!!~^^:::::^~!!77~^^:.^~~!77??7!~~~^^^~~~~!77?J5PGBB##G5P55555555PP?777!777777777777!777
    Y~~~~~~~~~~!J!!~^^^^~~~!7??7!~~~~~!77?7???7!7!!~~~~!!7??JJYPPGBBGBP5P55555555PP?777777777!!!7777777!
    Y~~~~~~~~~~~!7!!~~~!!?JYY7~!Y55YJY5PPGGGP57~?J?7!!!7??JJY5PPGPGGGPPPP55555555PP?777?7!7777!777!7777!
    Y~~~~~~~~~~~~77777?JY55Y7~~~7?J5PGGBBGG5YJ7!77JYJ??JJYY55PPGGGGGPP5PPPPP55P55PP?7777!!7777!777777777
    Y~!!!!~~~~~~~7???JY5P5J7!!~!~~^~?JYJ?77777777??JYYYYYY55PPGGGPPP55PPPPPPPPP55PPJ77777777777777777777
    Y~!!!!!~!!!!~7??7J5PY?7777!!!!!!!!!!!77?77?JJJJ??YYJJY55PPGGGP555PPPPPPPPPPPPPPJ!7777777777777!77777
    Y~!!!!!!!!!!!!777?J?????JJ???JJJ?7???JJYYYY555JJJYJ??JY5PGGG##BPPPPPPPPPPPPPPPPJ77777777777777777??7
    Y!!!!!!!!!!!7JJ777!!7?JY5PGGGGGPPPGGGGGBGGGGGGPYYY7!JY5PPBBB&&&&&####BBGPPPPPPGJ77777777777777777??7
    Y!!!!!!!!!!JPGP??7!!7?JYYY5PGGPPPPGGGGGBBBGPPPP5YJ7?Y5GGGB#&&&&&&&&&&&&&#BGPPPGY7777????????????????
    Y!!!!!!!!75GG#&GYJ?????7!??7?YYYYYYY5P5YJJY55J??JJJY5GBBB#&@@@@@&&&&&&&@&&#BGGG55YYYY555555555555555
    577??????5GB#&&&B5YJJ?7!!7JYJ?7777!777?JYPGPY????JYPBBBB#&&&@@@&&&&&&&###&###BGGPPPPPPPPPPPPPPPPPPPP
    GY5YY555PGB#&&&&&#P5J?7!777?Y55PPPPPPPGGGGPYJJJ??YPBBB###&@@@@@&&&&&&&&#B###BBBBBBPPPPPPPPPPPPPPPPPP
    G5555Y~!GGB#&&&&&&&GYY?7!7!!7?J555555555YY?7??7?YGBBB####@@@@@@&&#BBB&&&&###BBB##BPPPPPPPPPPPPPPPPGP
    BPPPJ!~YGG#&&&&&&&&&BGPJ7!!!~^^~~!!!!777777777YPGB######&&@@@@&&#BBG#&&&@@&&####BGPPPPPPPPPPPPPPPPGP
    #G5?!!Y5GGG#&&&&&&&&&###PJ7?7!!!!777777777?YY5GBB#######&&@@@@&&&#&##&&@@@@@&&#BGPPPPPPPPPPPPPPPPPPP
    PJ7!~J?7PGGB&&&&&&&&&&&###GPYJJ?JJ?JJJJ?J5GGGBBBB#######&&@@@&&@@&&&#&@@@@@@@@&####BGGGPPPPPGPPPPPGP
    G7:.^!. ~GGG#&&&&&&&&&&&&&&&#BGPP55Y555PB##BBBBBBBBB###&&&&@@&&@@@&&&&@@@@@@@@@&&&&&####BBGGPPPPGGGP
    G5?:J!^^:YGB#&&&&&&&&&&&&&&&&&&&###########BBBBBBBBBB###&&&@@&&&@@&#&@@@@@@@@&&&&&&&########BBGGGGGP
    J~^^!^....5GB#&&&&&&&&&&&&&&&&&&&&#########BBBBBBBBBBBB##&&@&&&@@@@&&@@@@@@@@&&&&&&&&&#########BBGGP
    5!~~:~:.^^~GB#&&&&&&&###&&&&##&&&&&########BBBBBBBBBBGGBBB##B#&@@@@@@@@@@@@@@@@@@@@@&&#############G
    5??55?7!7??5BB#&&##&#####&&&&&&&#&&&#######BBBBBBBBGGPPPPPP5Y#&&@@@@@@@@@@@@@@@@@@@@@@&&####B######B
    GJ?JPY???77YGBBBBB##B#B####&&&&&###&######BBBBBBBBGP55555YY75&&@@@@@&&@@@@@@@@@@@@@@@&&&&##########B
    #PP5JJ?????5PG&&&BB###B###&&###&#########BBBBBBBGP55555YYJ!!5#&&@@@@@&&&@@@@@@@@@@@@@&&&&##########B
    BGGPPGGPP55PB###&&BBB##&&&&#&########&&###B#BBBGP5YYYYYJ7~^~JB&&&@@@@@@&@@@@@@@@@@@@&&&&&##########B
    &##BGGGGGGGGGBBPB&&#####&&&&&&&&&&&&&&&&&#BPPP55YJJJJ?7~^~~~7G#&&&@@@@@&@@@@@@@@@@@@@&&&&&#########B
    &#&&&#BBGGGGGBBB#&&&&&#B#&&&&&&&&&&&&&&&&&#GGGPPPP5PP555J7~~!5#&&&@@@&&&@@@@@@@@@&@@&&&&&&&&#######B
    #BBB##&&&#BBBBBB#&&@@&&##&####&&&&&&&&&&&&@@#######&&&&&&#G5JJG#&&&&&&&@@@@@@@@@@@&&&&&&&&&&&######B
    #BBBBBBB#&&&###BB#&&&&B#####B#&&&&##&&&&&@@&&&#####&&&#######GPB&&&&&&@&@@@&@@@@&&&&&&@@@@&&&&#####B
    #BBBP?YJY57P5?G&&?#&#PJJPG5P?J5PJY?JG55JJP&@@&#GJY?YPPYJYYY!Y77GGPYJGP?JJ?GYBYP#&&&&&&@@@@&&&&#####B
    #BBB5??!YY!?J?5GYJY#BY?Y5P?J??YPJ77PP!?7??&&#&&B!JJP??JY?YY^J!J5GG7PBJ!~~!PY#JP#&&@@@@@@@@&&&&&####B
    #BBBBBP5BBPPP5P5G#BPB#BB&#GPBGBGPGBPGPGGGB&&P&&BBPBPGBGPP#P5BPPG&G5#&G&#GGGG@B#@&@@@@@@@@@&&&&&####B
    #BBBBBBBBB#######B#&###&##&&##&&&&&@@@@@@&&&&&&&&####BBB#BB######&B#&@@@@@@@@@@@@@@@@@@@@@&&&&&&###B
    #BBBBBBBBBBBBBBB#BB#####&&&&####&&&&&&@&&&&&&&&&#BBGGBGBGBBB##&&&&&&&@@@@@@@@@@@@@@@@@@@@&&&&&&&###B
    ############################################################################我去, 我劝年轻人要耗子尾汁🐴
    */ /* 生成地址: https://www.text-image.com/convert/result.cgi */
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (
      HttpClient client,
    ) {
      client.badCertificateCallback = (
        X509Certificate cert,
        String host,
        int port,
      ) =>
          true;
      return client;
    };
  }

  /// error统一处理
  static void handleError(DioError e) {
    switch (e.type) {
      case DioErrorType.connectionTimeout:
        debugPrint("连接超时");
        break;
      case DioErrorType.sendTimeout:
        debugPrint("请求超时");
        break;
      case DioErrorType.receiveTimeout:
        debugPrint("响应超时");
        break;
      case DioErrorType.badResponse:
        debugPrint("出现异常");
        break;
      case DioErrorType.cancel:
        debugPrint("请求取消");
        break;
      default:
        debugPrint("未知错误");
        break;
    }
  }

  /// get请求
  static Future get(String url, [Map<String, dynamic>? params]) async {
    Response response;
    if (params != null) {
      response = await dio.get(url, queryParameters: params);
    } else {
      response = await dio.get(url);
    }
    return response.data;
  }

  /// post 表单请求
  static Future post(String url, [Map<String, dynamic>? params]) async {
    Response response = await dio.post(url, queryParameters: params);
    return response.data;
  }

  /// post body请求
  static Future postJson(String url, [Map<String, dynamic>? data]) async {
    Response response = await dio.post(url, data: data);
    return response.data;
  }
}
