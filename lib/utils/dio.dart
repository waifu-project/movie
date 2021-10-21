import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

Dio createDio() {
  var dio = Dio();
  var cookieJar = CookieJar();
  dio.interceptors
    ..add(LogInterceptor())
    ..add(CookieManager(cookieJar));
  return dio;
}

var dio = createDio();
