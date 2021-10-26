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

import 'package:equatable/equatable.dart';

import 'avdata.dart';

class Data extends Equatable {
  final List<Avdata>? avdatas;
  final dynamic totalCount;

  const Data({this.avdatas, this.totalCount});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        avdatas: (json['avdatas'] as List<dynamic>?)
            ?.map((e) => Avdata.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalCount: json['total_count'],
      );

  Map<String, dynamic> toJson() => {
        'avdatas': avdatas?.map((e) => e.toJson()).toList(),
        'total_count': totalCount,
      };

  Data copyWith({
    List<Avdata>? avdatas,
    int? totalCount,
  }) {
    return Data(
      avdatas: avdatas ?? this.avdatas,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  List<Object?> get props => [avdatas, totalCount];
}
