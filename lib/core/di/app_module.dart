import 'package:app_links/app_links.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@module
abstract class AppModule {
  @lazySingleton
  Logger get logger => Logger(printer: CustomLogPrinter());
  @lazySingleton
  AppRouter get appRouter => AppRouter();
  @singleton
  AppLinks get appLinks => AppLinks();
}

class CustomLogPrinter extends LogPrinter {
  static const AnsiColor green = AnsiColor.fg(28);
  static const AnsiColor red = AnsiColor.fg(196);
  static const AnsiColor blue = AnsiColor.fg(33);
  static const AnsiColor yellow = AnsiColor.fg(226);

  @override
  List<String> log(LogEvent event) {
    final color = _getColor(event.level);
    final lines = event.message.toString().split('\n');

    final borderTop = green('┌${'─' * 80}');
    final borderBottom = green('└${'─' * 80}');

    final logLines = [borderTop, for (final line in lines) green('│ ') + color(line), borderBottom];

    return logLines;
  }

  AnsiColor _getColor(Level level) {
    switch (level) {
      case Level.error:
        return red;
      case Level.warning:
        return yellow;
      case Level.info:
        return blue;
      case Level.debug:
        return green;
      default:
        return const AnsiColor.none();
    }
  }
}
