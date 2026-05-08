import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Android foreground service isolate uchun. Asosiy WebSocket asosiy isolate’da qoladi.
@pragma('vm:entry-point')
void vendorOrdersForegroundTaskStartCallback() {
  FlutterForegroundTask.setTaskHandler(VendorOrdersForegroundTaskHandler());
}

class VendorOrdersForegroundTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}
