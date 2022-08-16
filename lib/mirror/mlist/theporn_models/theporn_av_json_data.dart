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

import 'data.dart';

class ThepornAvJsonData extends Equatable {
  final int? code;
  final String? msg;
  final Data? data;
  final String? description;

  const ThepornAvJsonData({
    this.code,
    this.msg,
    this.data,
    this.description,
  });

  factory ThepornAvJsonData.fromJson(Map<String, dynamic> json) {
    return ThepornAvJsonData(
      code: json['code'] as int?,
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
        'data': data?.toJson(),
        'description': description,
      };

  ThepornAvJsonData copyWith({
    int? code,
    String? msg,
    Data? data,
    String? description,
  }) {
    return ThepornAvJsonData(
      code: code ?? this.code,
      msg: msg ?? this.msg,
      data: data ?? this.data,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [code, msg, data, description];
}
