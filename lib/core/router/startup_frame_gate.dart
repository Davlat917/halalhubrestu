import 'package:flutter/widgets.dart';

/// App startda birinchi frame'ni guard tugaguncha ushlab turish uchun gate.
abstract final class StartupFrameGate {
  static bool _opened = false;

  static void open() {
    if (_opened) return;
    _opened = true;
    debugPrint('[StartupFrameGate] allowFirstFrame');
    WidgetsBinding.instance.allowFirstFrame();
  }
}
