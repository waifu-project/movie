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
