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

import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final List<dynamic>? resolution;

  const Video({this.resolution});

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        resolution: json['resolution'] as List<dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'resolution': resolution,
      };

  Video copyWith({
    List<int>? resolution,
  }) {
    return Video(
      resolution: resolution ?? this.resolution,
    );
  }

  @override
  List<Object?> get props => [resolution];
}
