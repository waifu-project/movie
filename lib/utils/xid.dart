// The lib copy by: https://github.com/pitabwire/xid

import 'dart:math';

import "dart:typed_data";

const String _base32Chars = "0123456789ABCDEFGHIJKLMNOPQRSTUV";

String base32encode(List<int> input) {
  Uint8List bytes = input is Uint8List ? input : Uint8List.fromList(input);
  int i = 0, index = 0, digit = 0;
  int currByte, nextByte;
  StringBuffer base32 = StringBuffer();

  while (i < bytes.length) {
    currByte = (bytes[i] >= 0) ? bytes[i] : (bytes[i] + 256);

    if (index > 3) {
      if ((i + 1) < bytes.length) {
        nextByte = (bytes[i + 1] >= 0) ? bytes[i + 1] : (bytes[i + 1] + 256);
      } else {
        nextByte = 0;
      }

      digit = currByte & (0xFF >> index);
      index = (index + 5) % 8;
      digit <<= index;
      digit |= nextByte >> (8 - index);
      i++;
    } else {
      digit = (currByte >> (8 - (index + 5)) & 0x1F);
      index = (index + 5) % 8;
      if (index == 0) {
        i++;
      }
    }
    base32.write(_base32Chars[digit]);
  }
  return base32.toString();
}

const List<int> _base32Lookup = [
  0x00,
  0x01,
  0x02,
  0x03,
  0x04,
  0x05,
  0x06,
  0x07,
  // '0', '1', '2', '3', '4', '5', '6', '7'
  0x08,
  0x09,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  // '8', '9', ':', ';', '<', '=', '>', '?'
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  // '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G'
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  // 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O'
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  // 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W'
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  // 'X', 'Y', 'Z', '[', '\', ']', '^', '_'
  0xFF,
  0x0A,
  0x0B,
  0x0C,
  0x0D,
  0x0E,
  0x0F,
  0x10,
  // '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g'
  0x11,
  0x12,
  0x13,
  0x14,
  0x15,
  0x16,
  0x17,
  0x18,
  // 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o'
  0x19,
  0x1A,
  0x1B,
  0x1C,
  0x1D,
  0x1E,
  0x1F,
  0xFF,
  // 'p', 'q', 'r', 's', 't', 'u', 'v', 'w'
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF
  // 'x', 'y', 'z', '{', '|', '}', '~', 'DEL'
];

List<int> base32decode(String input) {
  int index = 0, lookup, offset = 0, digit;
  Uint8List bytes = Uint8List(input.length * 5 ~/ 8);

  for (int i = 0; i < input.length; i++) {
    lookup = input.codeUnitAt(i) - 48;
    if (lookup < 0 || lookup >= _base32Lookup.length) continue;

    digit = _base32Lookup[lookup];
    if (digit == 0xFF) continue;

    if (index <= 3) {
      index = (index + 5) % 8;
      if (index == 0) {
        bytes[offset] |= digit;
        offset++;
        if (offset >= bytes.length) break;
      } else {
        bytes[offset] |= digit << (8 - index);
      }
    } else {
      index = (index + 5) % 8;
      bytes[offset] |= (digit >> index);
      offset++;

      if (offset >= bytes.length) break;

      bytes[offset] |= digit << (8 - index);
    }
  }
  return bytes;
}

class InvalidXidException implements Exception {}

const String _allChars = "0123456789abcdefghijklmnopqrstuv";

///
/// A globally unique identifier for objects.
///
/// <p>Consists of 12 bytes, divided as follows:</p>
///  <table border="1">
///   <caption>layout</caption>
///   <tr><td>0</td><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td><td>6</td><td>7</td><td>8</td><td>9</td><td>10</td><td>11</td></tr>
///   <tr><td colspan="4">time</td><td colspan="5">random value</td><td colspan="3">inc</td></tr>
/// </table>
///
///  Instances of this class are immutable.
///
class Xid {
  static String? _machineId;
  static int? _processId;
  static int? _counterInt;

  List<int>? _xidBytes;

  /// Creates a new instance of xid
  Xid() {
    _generateXid();
  }

  ///
  /// Constructs a new instance of xid from the given a string of xid
  /// throws InvalidXidException if the string supplied is not a valid xid
  Xid.fromString(String newXid) {
    if (!_isValid(newXid)) {
      throw InvalidXidException();
    }
    _xidBytes = _toBytes(newXid);
  }

  String _toHexString() {
    return base32encode(_xidBytes!);
  }

  List<int> _toBytes(String xid) {
    return base32decode(xid);
  }

  /// Creates and returns a new instance of xid
  static Xid get() {
    return Xid();
  }

  /// Creates a new instance of xid and returns the string representation
  static String string() {
    return get().toString();
  }

  bool _isValid(String xid) {
    if (xid.length != 20) {
      return false;
    }

    var allowedChars = _allChars.split('');

    for (int i = 0; i < xid.length; i++) {
      var c = xid[i];
      if (allowedChars.contains(c)) {
        continue;
      }

      return false;
    }

    return true;
  }

  List<int> _getMachineId() {
    if (_machineId != null) {
      return _toBytes(_machineId!);
    }

    _processId = Random.secure().nextInt(4194304);
    _machineId = Random.secure().nextInt(5170000).toString();
    return _toBytes(_machineId!);
  }

  static int _counter() {
    _counterInt ??= Random.secure().nextInt(16777215);
    _counterInt = _counterInt! + 1;

    return _counterInt!;
  }

  String _generateXid() {
    var now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var counter = _counter();
    var machineID = _getMachineId();

    _xidBytes = List.filled(20, 0, growable: false);

    _xidBytes![0] = (now >> 24) & 0xff;
    _xidBytes![1] = (now >> 16) & 0xff;
    _xidBytes![2] = (now >> 8) & 0xff;
    _xidBytes![3] = (now) & 0xff;

    _xidBytes![4] = machineID[0];
    _xidBytes![5] = machineID[1];
    _xidBytes![6] = machineID[2];

    _xidBytes![7] = (_processId! >> 8) & 0xff;
    _xidBytes![8] = (_processId!) & 0xff;

    _xidBytes![9] = (counter >> 16) & 0xff;
    _xidBytes![10] = (counter >> 8) & 0xff;
    _xidBytes![11] = (counter) & 0xff;

    return _toHexString();
  }

  @override
  String toString() {
    return _toHexString().toLowerCase().substring(0, 20);
  }

  /// Returns the byte representation of the current xid instance
  List<int> toBytes() {
    return [...?_xidBytes];
  }
}