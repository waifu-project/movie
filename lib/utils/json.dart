// ignore_for_file: non_constant_identifier_names

var MAGIC_START_SYMBOL = [
  "[",
  "{",
];

var MAGIC_END_SYMBOL = [
  "]",
  "}",
];

enum JSONBodyType {

  /// 对象
  /// 
  /// ```
  /// {}
  /// ```
  obj,

  /// 数组
  /// 
  /// ```
  /// []
  /// ```
  array,
}

/// 获取 [json] 的类型
/// 
/// 使用 [verifyStringIsJSON] 判断是否是 [json] 字符串
JSONBodyType? getJSONBodyType(String data) {
  data = data.trim();
  if (data.startsWith(MAGIC_START_SYMBOL[0])) {
    return JSONBodyType.array;
  } else if (data.startsWith(MAGIC_START_SYMBOL[1])) {
    return JSONBodyType.obj;
  } else {
    return null;
  }
}

/// 用最二逼的方式校验是否是正确的`json`格式
///
/// [vJSON] 待校验的json字符串
///
/// [return] 是否是正确的json格式
bool verifyStringIsJSON(String vJSON) {
  var target = vJSON.trim();
  String start = target[0];
  String end = target[target.length - 1];
  return [0, 1].any((index) {
    bool startFlag = MAGIC_START_SYMBOL[index] == start;
    bool endFlag = MAGIC_END_SYMBOL[index] == end; 
    return startFlag && endFlag;
  });
}
