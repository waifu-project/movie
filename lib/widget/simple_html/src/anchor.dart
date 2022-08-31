import 'package:flutter/widgets.dart';

import 'styled_element.dart';

class AnchorKey extends GlobalKey {
  static final Set<AnchorKey> _registry = <AnchorKey>{};

  final Key parentKey;
  final String id;

  const AnchorKey._(this.parentKey, this.id) : super.constructor();

  static AnchorKey? of(Key? parentKey, StyledElement? id) {
    final key = forId(parentKey, id?.elementId);
    if (key == null || _registry.contains(key)) {
      // Invalid id or already created a key with this id: silently ignore
      return null;
    }
    _registry.add(key);
    return key;
  }

  static AnchorKey? forId(Key? parentKey, String? id) {
    if (parentKey == null || id == null || id.isEmpty || id == "[[No ID]]") {
      return null;
    }

    return AnchorKey._(parentKey, id);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnchorKey && runtimeType == other.runtimeType && parentKey == other.parentKey && id == other.id;

  @override
  int get hashCode => parentKey.hashCode ^ id.hashCode;

  @override
  String toString() {
    return 'AnchorKey{parentKey: $parentKey, id: #$id}';
  }
}
