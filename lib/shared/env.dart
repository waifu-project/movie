import 'dart:io';

class CMEnvs {
  static String debug = "CM_DEBUG";
  static String fullHttpLog = "CM_FULL_HTTP_LOG";
}

class CMEnv {
  static bool _isTrue(String? env) {
    if (env == null) return false;
    return env == "true" || env == "1";
  }

  static bool get isDebug {
    String env = Platform.environment[CMEnvs.debug] ?? "false";
    return _isTrue(env);
  }

  static bool get enableFullHttpLog {
    String env = Platform.environment[CMEnvs.fullHttpLog] ?? "false";
    return _isTrue(env);
  }
}
