import 'package:equatable/equatable.dart';

import 'avdata.dart';

class Data extends Equatable {
	final List<Avdata>? avdatas;
	final int? totalCount;

	const Data({this.avdatas, this.totalCount});

	factory Data.fromJson(Map<String, dynamic> json) => Data(
				avdatas: (json['avdatas'] as List<dynamic>?)
						?.map((e) => Avdata.fromJson(e as Map<String, dynamic>))
						.toList(),
				totalCount: json['total_count'] as int?,
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
