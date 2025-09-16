// https://pub.dev/packages/haptic_feedback
// https://github.com/istornz/flutter_gaimon

import 'package:catmovie/shared/enum.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:catmovie/app/extension.dart';

class Boop {
  late bool canVibrate;

  bool enabled = true;

  bool setEnabled(bool value) {
    if (value == enabled) return false;
    updateSetting(SettingsAllKey.hapticFeedback, value);
    enabled = value;
    return true;
  }

  Future<bool> init() async {
    canVibrate = await Haptics.canVibrate();
    return canVibrate;
  }

  Future<void> call(HapticsType type, {bool force = false}) async {
    if ((!canVibrate || !enabled) && !force) return;
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
