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

import 'package:flappy_search_bar_ns/flappy_search_bar_ns.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

// https://blog.smartnsoft.com/an-automatic-search-bar-in-flutter-flappy-search-bar-a470bc67fa1f

class SearchView extends GetView {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SearchBar<dynamic>(
          onItemFound: (item, int index) {
            return Container(
              child: Center(
                child: Text("#future"),
              ),
            );
          },
          onSearch: (String? text) async {
            return [];
          },
        ),
      ),
    );
  }
}
