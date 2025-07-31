import 'package:flutter/cupertino.dart';
import 'package:flutter_js/extensions/fetch.dart';
import 'package:flutter_js/extensions/xhr.dart';
import 'package:flutter_js/flutter_js.dart';

class JSRuntime {
  late JavascriptRuntime _cx;
  JavascriptRuntime get cx => _cx;
  JSRuntime() {
    _cx = getJavascriptRuntime();
    withInit();
  }

  void withInit() {
    _cx.enableFetch();
    _cx.enableHandlePromises();
    _cx.enableXhr();
  }

  void echo() async {
    var x = await _cx.evaluateAsync("""
function getHome() {
  return new Promise(async res=> {
    const resp = await fetch("https://api.52vmy.cn/api/img/tu/girl")
    const cx = await resp.text()
    res({ "hello": cx })
  })
};
await getHome()
""");
    debugPrint("xx");
  }
}

var jsRuntime = JSRuntime();
