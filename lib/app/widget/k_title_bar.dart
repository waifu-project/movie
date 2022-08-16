// Copyright (C) 2021-2022 d1y <chenhonzhou@gmail.com>
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class kTitleBar extends StatelessWidget {
  final String title;

  const kTitleBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 4,
                color: Colors.black,
                width: 82,
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "全部",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Icon(CupertinoIcons.arrow_right_circle),
            ],
          )
        ],
      ),
    );
  }
}
