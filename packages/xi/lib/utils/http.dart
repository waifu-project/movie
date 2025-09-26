import 'dart:io';

import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'path.dart';
// import 'package:native_dio_adapter/native_dio_adapter.dart';

/// dio http 请求库缓存时间
const kHttpCacheTime = Duration(hours: 2);

const kConnectTimeout = Duration(seconds: 12);
const kReceiveTimeout = Duration(seconds: 12);

extension DioWithForceNoCache on Options {
  Options withNoCache() {
    extra ??= {};
    extra!["no-cache"] = true;
    return this;
  }
}

/// 默认所有的 `dio-http` 请求都持久化话([kHttpCacheTime])
///
/// 此扩展可以修改 `options` 控制缓存行为
/// ```dart
/// var resp = await XHttp.dio.get(
///  fetchMirrorAPI,
///  options: $noCacheOption,
/// );
///```
extension AnyInjectHttpCacheOptions on Object {
  Options $noCacheOption() {
    return Options().withNoCache();
  }
}

var kHttpCacheMiddlewareOptions = CacheOptions(
  store: MemCacheStore(),
  policy: CachePolicy.forceCache,
  hitCacheOnErrorCodes: const [401, 403],
  maxStale: kHttpCacheTime,
  priority: CachePriority.normal,
  cipher: null,
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  allowPostMethod: true,
);

class XHttp {
  XHttp._internal();

  /// 网络请求配置
  static final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: {
        "User-Agent":
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36",
      },
    ),
  );

  static void setDefaultTImeout() {
    dio.options.connectTimeout = kConnectTimeout;
    dio.options.receiveTimeout = kReceiveTimeout;
  }

  static void setTimeout(int connect, int receive) {
    dio.options.connectTimeout = Duration(seconds: connect);
    dio.options.receiveTimeout = Duration(seconds: receive);
  }

  /// 初始化dio
  static Future<void> init({bool enableLog = false}) async {
    /// 初始化cookie
    var value = await PathUtils.getDocumentsDirPath();
    var cookieJar = PersistCookieJar(
      storage: FileStorage("$value/.cookies/"),
    );
    dio.interceptors.add(CookieManager(cookieJar));

    dio.interceptors
        .add(DioCacheInterceptor(options: kHttpCacheMiddlewareOptions));

    if (enableLog) {
      dio.interceptors.add(
        AwesomeDioInterceptor(
          logRequestTimeout: true,
          logRequestHeaders: true,
          logResponseHeaders: true,
          logger: debugPrint,
        ),
      );
    }

    // if (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) {
    //   // TODO(d1y): 这里需要忽律掉证书错误的域名
    //   dio.httpClientAdapter = NativeAdapter(createCupertinoConfiguration: () {
    //     return URLSessionConfiguration.defaultSessionConfiguration()
    //       ..allowsCellularAccess = true
    //       ..allowsConstrainedNetworkAccess = true
    //       ..allowsExpensiveNetworkAccess = true;
    //   }, createCronetEngine: () {
    //     return CronetEngine.build(enableHttp2: true, enableQuic: true);
    //   });
    // } else {
    dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    });
    // }
  }

  static Future<T> get<T>(String url, [Map<String, dynamic>? params]) async {
    Response response;
    if (params != null) {
      response = await dio.get<T>(url, queryParameters: params);
    } else {
      response = await dio.get<T>(url);
    }
    return response.data;
  }

  static Future<T> post<T>(String url, [Map<String, dynamic>? params]) async {
    Response response = await dio.post<T>(url, queryParameters: params);
    return response.data;
  }

  static Future<T> postWithBody<T>(String url,
      [Map<String, dynamic>? data]) async {
    Response response = await dio.post<T>(url, data: data);
    return response.data;
  }
}
