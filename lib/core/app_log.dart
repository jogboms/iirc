import 'package:logging/logging.dart';

class AppLog {
  AppLog._();

  static final Logger _logger = Logger.root;

  static void init({
    required _LogFilter logFilter,
    required _ExceptionFilter exceptionFilter,
    required _ExceptionLogger onException,
    required _Logger onLog,
  }) {
    _logger.level = Level.ALL;
    _logger.onRecord.listen(_logListener(logFilter, exceptionFilter, onException, onLog));
  }

  static void e(Object error, StackTrace stackTrace, {Object? message}) => _logger.log(
        Level.SEVERE,
        message ?? error.toString(),
        error,
        error is Error && error.stackTrace != null ? error.stackTrace! : stackTrace,
      );

  static void i(Object message) => _logger.info(message);
}

typedef _LogFilter = bool Function();
typedef _Logger = void Function(Object? message);
typedef _ExceptionFilter = bool Function(Object error);
typedef _ExceptionLogger = void Function(Object error, StackTrace stackTrace, Object extra);

void Function(LogRecord) _logListener(
  _LogFilter logFilter,
  _ExceptionFilter exceptionFilter,
  _ExceptionLogger onException,
  _Logger onLog,
) =>
    (LogRecord record) {
      final _Logger logger = logFilter() ? onLog : (_) {};
      if (record.level != Level.SEVERE) {
        logger(record.message);
        return;
      }

      logger(record.error);
      logger(record.stackTrace);

      final Object error = record.error!;
      if (!exceptionFilter(error)) {
        return;
      }

      onException(
        error,
        record.stackTrace ?? StackTrace.current,
        record.object ?? <String, dynamic>{},
      );
    };
