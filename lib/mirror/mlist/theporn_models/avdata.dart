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

import 'space_host.dart';
import 'video.dart';

class Avdata extends Equatable {
  final int? tid;
  final String? title;
  final int? viewCount;
  final int? likeCount;
  final int? dislikeCount;
  final bool? vr;
  final int? avDataType;
  final String? hashId;
  final String? staticHost;
  final String? spaceName;
  final String? releaseTimeFormat;
  final List<SpaceHost>? spaceHosts;
  final String? cdnHost;
  final String? smallCoverImageUrl;
  final String? bigCoverImageUrl;
  final String? embedIframeUrl;
  final bool? isVipVideo;
  final dynamic preview;
  final bool? vipVideo;
  final Video? video;
  final double? duration;
  final bool? existsHighResolution;
  final String? javId;
  final List<dynamic>? categories;
  final List<dynamic>? actress;

  const Avdata({
    this.tid,
    this.title,
    this.viewCount,
    this.likeCount,
    this.dislikeCount,
    this.vr,
    this.avDataType,
    this.hashId,
    this.staticHost,
    this.spaceName,
    this.releaseTimeFormat,
    this.spaceHosts,
    this.cdnHost,
    this.smallCoverImageUrl,
    this.bigCoverImageUrl,
    this.embedIframeUrl,
    this.isVipVideo,
    this.preview,
    this.vipVideo,
    this.video,
    this.duration,
    this.existsHighResolution,
    this.javId,
    this.categories,
    this.actress,
  });

  factory Avdata.fromJson(Map<String, dynamic> json) => Avdata(
        tid: json['tid'] as int?,
        title: json['title'] as String?,
        viewCount: json['view_count'] as int?,
        likeCount: json['like_count'] as int?,
        dislikeCount: json['dislike_count'] as int?,
        vr: json['vr'] as bool?,
        avDataType: json['av_data_type'] as int?,
        hashId: json['hash_id'] as String?,
        staticHost: json['static_host'] as String?,
        spaceName: json['space_name'] as String?,
        releaseTimeFormat: json['release_time_format'] as String?,
        spaceHosts: (json['space_hosts'] as List<dynamic>?)
            ?.map((e) => SpaceHost.fromJson(e as List<dynamic>))
            .toList(),
        cdnHost: json['cdn_host'] as String?,
        smallCoverImageUrl: json['small_cover_image_url'] as String?,
        bigCoverImageUrl: json['big_cover_image_url'] as String?,
        embedIframeUrl: json['embed_iframe_url'] as String?,
        isVipVideo: json['is_vip_video'] as bool?,
        preview: json['preview'] as dynamic?,
        vipVideo: json['vip_video'] as bool?,
        video: json['video'] == null
            ? null
            : Video.fromJson(json['video'] as Map<String, dynamic>),
        duration: (json['duration'] as num?)?.toDouble(),
        existsHighResolution: json['exists_high_resolution'] as bool?,
        javId: json['jav_id'] as String?,
        categories: json['categories'] as List<dynamic>?,
        actress: json['actress'] as List<dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'tid': tid,
        'title': title,
        'view_count': viewCount,
        'like_count': likeCount,
        'dislike_count': dislikeCount,
        'vr': vr,
        'av_data_type': avDataType,
        'hash_id': hashId,
        'static_host': staticHost,
        'space_name': spaceName,
        'release_time_format': releaseTimeFormat,
        'space_hosts': spaceHosts?.map((e) => e.toJson()).toList(),
        'cdn_host': cdnHost,
        'small_cover_image_url': smallCoverImageUrl,
        'big_cover_image_url': bigCoverImageUrl,
        'embed_iframe_url': embedIframeUrl,
        'is_vip_video': isVipVideo,
        'preview': preview,
        'vip_video': vipVideo,
        'video': video?.toJson(),
        'duration': duration,
        'exists_high_resolution': existsHighResolution,
        'jav_id': javId,
        'categories': categories,
        'actress': actress,
      };

  Avdata copyWith({
    int? tid,
    String? title,
    int? viewCount,
    int? likeCount,
    int? dislikeCount,
    bool? vr,
    int? avDataType,
    String? hashId,
    String? staticHost,
    String? spaceName,
    String? releaseTimeFormat,
    List<SpaceHost>? spaceHosts,
    String? cdnHost,
    String? smallCoverImageUrl,
    String? bigCoverImageUrl,
    String? embedIframeUrl,
    bool? isVipVideo,
    dynamic preview,
    bool? vipVideo,
    Video? video,
    double? duration,
    bool? existsHighResolution,
    String? javId,
    List<String>? categories,
    List<String>? actress,
  }) {
    return Avdata(
      tid: tid ?? this.tid,
      title: title ?? this.title,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      vr: vr ?? this.vr,
      avDataType: avDataType ?? this.avDataType,
      hashId: hashId ?? this.hashId,
      staticHost: staticHost ?? this.staticHost,
      spaceName: spaceName ?? this.spaceName,
      releaseTimeFormat: releaseTimeFormat ?? this.releaseTimeFormat,
      spaceHosts: spaceHosts ?? this.spaceHosts,
      cdnHost: cdnHost ?? this.cdnHost,
      smallCoverImageUrl: smallCoverImageUrl ?? this.smallCoverImageUrl,
      bigCoverImageUrl: bigCoverImageUrl ?? this.bigCoverImageUrl,
      embedIframeUrl: embedIframeUrl ?? this.embedIframeUrl,
      isVipVideo: isVipVideo ?? this.isVipVideo,
      preview: preview ?? this.preview,
      vipVideo: vipVideo ?? this.vipVideo,
      video: video ?? this.video,
      duration: duration ?? this.duration,
      existsHighResolution: existsHighResolution ?? this.existsHighResolution,
      javId: javId ?? this.javId,
      categories: categories ?? this.categories,
      actress: actress ?? this.actress,
    );
  }

  @override
  List<Object?> get props {
    return [
      tid,
      title,
      viewCount,
      likeCount,
      dislikeCount,
      vr,
      avDataType,
      hashId,
      staticHost,
      spaceName,
      releaseTimeFormat,
      spaceHosts,
      cdnHost,
      smallCoverImageUrl,
      bigCoverImageUrl,
      embedIframeUrl,
      isVipVideo,
      preview,
      vipVideo,
      video,
      duration,
      existsHighResolution,
      javId,
      categories,
      actress,
    ];
  }
}
