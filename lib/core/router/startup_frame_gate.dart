import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// App startda birinchi frame'ni guard tugaguncha ushlab turish uchun gate.
abstract final class StartupFrameGate {
  static bool _opened = false;

  static void open() {
    if (_opened) return;
    _opened = true;
    if (kDebugMode) debugPrint('[StartupFrameGate] allowFirstFrame');
    WidgetsBinding.instance.allowFirstFrame();
  }
}
