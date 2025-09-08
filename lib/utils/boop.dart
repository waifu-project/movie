// https://pub.dev/packages/haptic_feedback
// https://github.com/istornz/flutter_gaimon

import 'package:haptic_feedback/haptic_feedback.dart';

class Boop {
  late bool canVibrate;

  Future<bool> init() async {
    canVibrate = await Haptics.canVibrate();
    return canVibrate;
  }

  Future<void> call(HapticsType type) async {
    if (!canVibrate) return;
    await Haptics.vibrate(type);
  }

  Future<void> selection() async {
    await call(HapticsType.selection);
  }

  Future<void> success() async {
    await call(HapticsType.success);
  }

  Future<void> warning() async {
    await call(HapticsType.warning);
  }

  Future<void> error() async {
    await call(HapticsType.error);
  }
}

var boop = Boop();
