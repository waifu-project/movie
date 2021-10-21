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
