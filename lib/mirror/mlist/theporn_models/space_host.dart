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
