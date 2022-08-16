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

class SpaceHost {
  SpaceHost({
    this.data,
  });

  final List<dynamic>? data;

  // "space_hosts": [
  //   [
  //     "direct_hosts",
  //     "默认"
  //   ],
  //   [
  //     "cnservers",
  //     "默认2"
  //   ],
  //   [
  //     "lacdn",
  //     "海外1"
  //   ],
  //   [
  //     "cfserver",
  //     "海外2"
  //   ]
  // ]
  factory SpaceHost.fromJson(List<dynamic> json) {
    return SpaceHost(data: json);
  }

  dynamic toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
