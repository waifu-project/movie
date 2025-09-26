import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/extensions/fetch.dart';
import 'package:flutter_js/extensions/xhr.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:xi/xi.dart';

class JS2 {
  late JavascriptRuntime _runtime;

  Future<void> init() async {
    _runtime = getJavascriptRuntime();
    await _runtime.enableHandlePromises();
    await _runtime.enableFetch();
    await _installCheerio();
    _runtime.setInspectable(true);
    _runtime.enableXhr();
    _injectMethods();
  }

  void _injectMethods() {
    _runtime.injectMethod('req', (dynamic args) async {
      if (args is List && args.isNotEmpty) {
        String url = "";
        Options options = Options(
          responseType: ResponseType.plain,
        );
        var arg1 = args[0];
        Map argMap = {};

        if (args.length >= 2) {
          // [ "$url", { "headers", "method" } ]
          if (arg1 is String) {
            url = arg1;
          }
          var arg2 = args[1];
          if (arg2 is Map) {
            argMap = arg2;
          }
        } else if (args.length == 1) {
          // [ "$url" ] | [ { "headers", "method", "url" } ]
          if (arg1 is String) {
            url = arg1;
          } else if (arg1 is Map) {
            argMap = arg1;
          }
        }

        if (url.isEmpty && argMap.isNotEmpty) {
          url = argMap["url"]?.toString() ?? "";
        }

        if (url.isEmpty) {
          return "";
        }

        options.method = argMap["method"]?.toString() ?? "GET";

        Map<String, String> defaultHeaders = {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59'
        };

        argMap["headers"] ??= {};

        argMap["noCache"] ??= false;

        var bodyType = argMap["bodyType"] ?? "json";

        if (bodyType == "form") {
          defaultHeaders["Content-Type"] = "application/x-www-form-urlencoded";
        } else {
          defaultHeaders["Content-Type"] = "application/json";
        }

        if ((argMap["headers"] as Map).isNotEmpty) {
          var customHeaders = Map<String, String>.from(argMap["headers"]);
          defaultHeaders.addAll(customHeaders);
        }

        options.headers = defaultHeaders;

        if (bodyType == "form") {
          if (argMap["data"] is Map) {
            argMap["data"] = FormData.fromMap(argMap["data"]);
          }
        }

        if (argMap["noCache"] == true) {
          options = options.withNoCache();
        }

        var result = "";
        try {
          var resp = await XHttp.dio.request(
            url,
            options: options,
            data: argMap["data"],
            queryParameters: argMap["params"],
          );
          result = resp.data?.toString() ?? "";
        } catch (e) {
          // TODO(d1y): handle error
          debugPrint(e.toString());
        }
        return result;
      }
      return "";
    });
  }

  Future<void> _installCheerio() async {
    var result = await rootBundle.loadString(
      'packages/xi/assets/js/kitty.umd.js',
    );
    _runtime.evaluate("var window = global = globalThis;");
    _runtime.evaluate(result);
  }

  String eval(String code) {
    var result = _runtime.evaluate(code);
    return result.stringResult;
  }

  /// 在 JSCore 中似乎可以直接返回一个正确的序列化JSON
  /// 但是在 quickjs 中它会返回一个错误的序列化
  /// 例: [data: 你好]
  Future<String> _fixJSONStringify(JsEvalResult promise) async {
    // JScore
    if (Platform.isIOS || Platform.isMacOS) {
      return promise.stringResult;
    }
    // QuickJS
    var data = await promise.rawResult;
    var strResult = jsonEncode(data);
    return strResult;
  }

  Future<String> evalSync(String code, {Duration? timeout}) async {
    var result = await _runtime.evaluateAsync(code);
    var promise = await _runtime.handlePromise(result, timeout: timeout);
    return _fixJSONStringify(promise);
  }
}

var js2 = JS2();
