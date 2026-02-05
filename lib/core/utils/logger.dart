import 'package:goldmapapp/core/config/app_config.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: AppConfig.isDev ? Level.debug : Level.warning,
  );

  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConfig.enableLogging) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConfig.enableLogging) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  static void warning(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (AppConfig.enableLogging) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
