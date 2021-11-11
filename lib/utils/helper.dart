// Copyright (C) 2021 d1y <chenhonzhou@gmail.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// copy https://github.com/dart-league/validators/blob/master/lib/validators.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

RegExp _ipv4Maybe =
    new RegExp(r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$');
RegExp _ipv6 =
    new RegExp(r'^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$');

shift(List l) {
  if (l.length >= 1) {
    var first = l.first;
    l.removeAt(0);
    return first;
  }
  return null;
}

/// check if the string [str] is IP [version] 4 or 6
///
/// * [version] is a String or an `int`.
bool isIP(String? str, [/*<String | int>*/ version]) {
  version = version.toString();
  if (version == 'null') {
    return isIP(str, 4) || isIP(str, 6);
  } else if (version == '4') {
    if (!_ipv4Maybe.hasMatch(str!)) {
      return false;
    }
    var parts = str.split('.');
    parts.sort((a, b) => int.parse(a) - int.parse(b));
    return int.parse(parts[3]) <= 255;
  }
  return version == '6' && _ipv6.hasMatch(str!);
}

/// check if the string [str] is a fully qualified domain name (e.g. domain.com).
///
/// * [requireTld] sets if TLD is required
/// * [allowUnderscore] sets if underscores are allowed
bool isFQDN(String str,
    {bool requireTld = true, bool allowUnderscores = false}) {
  var parts = str.split('.');
  if (requireTld) {
    var tld = parts.removeLast();
    if (parts.length == 0 || !new RegExp(r'^[a-z]{2,}$').hasMatch(tld)) {
      return false;
    }
  }

  for (var part in parts) {
    if (allowUnderscores) {
      if (part.contains('__')) {
        return false;
      }
    }
    if (!new RegExp(r'^[a-z\\u00a1-\\uffff0-9-]+$').hasMatch(part)) {
      return false;
    }
    if (part[0] == '-' ||
        part[part.length - 1] == '-' ||
        part.indexOf('---') >= 0) {
      return false;
    }
  }
  return true;
}

/// check if the string [str] is a URL
///
/// * [protocols] sets the list of allowed protocols
/// * [requireTld] sets if TLD is required
/// * [requireProtocol] is a `bool` that sets if protocol is required for validation
/// * [allowUnderscore] sets if underscores are allowed
/// * [hostWhitelist] sets the list of allowed hosts
/// * [hostBlacklist] sets the list of disallowed hosts
bool isURL(String? str,
    {List<String?> protocols = const ['http', 'https', 'ftp'],
    bool requireTld = true,
    bool requireProtocol = false,
    bool allowUnderscore = false,
    List<String> hostWhitelist = const [],
    List<String> hostBlacklist = const []}) {
  if (str == null ||
      str.length == 0 ||
      str.length > 2083 ||
      str.startsWith('mailto:')) {
    return false;
  }

  var protocol,
      user,
      auth,
      host,
      hostname,
      port,
      port_str,
      path,
      query,
      hash,
      split;

  // check protocol
  split = str.split('://');
  if (split.length > 1) {
    protocol = shift(split);
    if (protocols.indexOf(protocol) == -1) {
      return false;
    }
  } else if (requireProtocol == true) {
    return false;
  }
  str = split.join('://');

  // check hash
  split = str!.split('#');
  str = shift(split);
  hash = split.join('#');
  if (hash != null && hash != "" && new RegExp(r'\s').hasMatch(hash)) {
    return false;
  }

  // check query params
  split = str!.split('?');
  str = shift(split);
  query = split.join('?');
  if (query != null && query != "" && new RegExp(r'\s').hasMatch(query)) {
    return false;
  }

  // check path
  split = str!.split('/');
  str = shift(split);
  path = split.join('/');
  if (path != null && path != "" && new RegExp(r'\s').hasMatch(path)) {
    return false;
  }

  // check auth type urls
  split = str!.split('@');
  if (split.length > 1) {
    auth = shift(split);
    if (auth.indexOf(':') >= 0) {
      auth = auth.split(':');
      user = shift(auth);
      if (!new RegExp(r'^\S+$').hasMatch(user)) {
        return false;
      }
      if (!new RegExp(r'^\S*$').hasMatch(user)) {
        return false;
      }
    }
  }

  // check hostname
  hostname = split.join('@');
  split = hostname.split(':');
  host = shift(split);
  if (split.length > 0) {
    port_str = split.join(':');
    try {
      port = int.parse(port_str, radix: 10);
    } catch (e) {
      return false;
    }
    if (!new RegExp(r'^[0-9]+$').hasMatch(port_str) ||
        port <= 0 ||
        port > 65535) {
      return false;
    }
  }

  if (!isIP(host) &&
      !isFQDN(host,
          requireTld: requireTld, allowUnderscores: allowUnderscore) &&
      host != 'localhost') {
    return false;
  }

  if (hostWhitelist.isNotEmpty && !hostWhitelist.contains(host)) {
    return false;
  }

  if (hostBlacklist.isNotEmpty && hostBlacklist.contains(host)) {
    return false;
  }

  return true;
}

/// 获取 [windows] 平台的主题
/// 参考:
///   => https://github.com/albertosottile/darkdetect/blob/master/darkdetect/_windows_detect.py
Brightness getWindowsThemeMode() {
  if (!GetPlatform.isWindows) return Brightness.light;
  
  // PS C:\Users\PureBoy> reg query HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /z /t REG_DWORD
  // HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize
  //     AppsUseLightTheme    REG_DWORD (4)    0x1
  // 搜索结束: 找到 1 匹配。

  // 0x1 => 浅色
  // 0x0 => 深色
  var pipe = Process.runSync("reg", [
    "query",
    "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
    "/v",
    "AppsUseLightTheme",
    "/z",
    "/t",
    "REG_DWORD"
  ]);
  var io2 = pipe.stdout.toString();
  return [
    {"k": "0x1", "v": Brightness.light},
    {"k": "0x0", "v": Brightness.dark},
  ].firstWhere((element) => io2.contains(element["k"] as String))["v"]
      as Brightness;
}
