import 'package:flutter/cupertino.dart';

VoidCallback once(VoidCallback cb) {
  var exec = false;
  return () {
    if (exec) return;
    exec = true;
    cb();
  };
}

ValueChanged<T> onceWithValue<T>(ValueChanged<T> cb) {
  var exec = false;
  return (T value) {
    if (exec) return;
    exec = true;
    cb(value);
  };
}