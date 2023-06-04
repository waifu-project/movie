import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/io.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:movie/utils/path.dart';

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
    dio.interceptors.add(LogInterceptor());

    /// 添加拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, handler) {
          // print("请求之前");
          return handler.next(options);
        },
        onResponse: (Response response, handler) {
          // print("响应之前");
          return handler.next(response);
        },
        onError: (DioError e, handler) {
          // print("错误之前");
          handleError(e);
          return handler.next(e);
        },
      ),
    );

    // 证书啥的, 都是访问的盗版资源, 无所谓
    //   ______          _
    //  |  ____|        | |
    //  | |__ _   _  ___| | __
    //  |  __| | | |/ __| |/ /
    //  | |  | |_| | (__|   <
    //  |_|   \__,_|\___|_|\_\
    //
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

  /// 下载文件
  // static Future downloadFile(urlPath, savePath) async {
  //   Response response;
  //   try {
  //     response = await dio.download(
  //       urlPath,
  //       savePath,
  //       onReceiveProgress: (int count, int total) {
  //         //进度
  //         print("$count $total");
  //       },
  //     );
  //   } on DioError catch (e) {
  //     handleError(e);
  //   }
  //   return response.data;
  // }

}
