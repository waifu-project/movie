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

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:movie/config.dart';
import 'package:movie/mirror/mirror.dart';

import 'app/routes/app_pages.dart';
import 'utils/http.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await XHttp.init();
  await GetStorage.init();
  await MirrorManage.init();
  final localStorage = GetStorage();
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: (localStorage.read(ConstDart.ls_isDark) ?? false)
            ? Brightness.dark
            : Brightness.light,
      ),
    ),
  );
}
