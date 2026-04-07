import 'package:logger/logger.dart';

/// Application logger configuration and utilities
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log verbose message (for detailed debugging)
  static void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Log debug message
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info message
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning message
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log API request
  static void logApiRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? queryParams,
    dynamic body,
  }) {
    info(
      '📡 API Request: $method $endpoint\n'
      '${queryParams != null ? 'Params: $queryParams\n' : ''}'
      '${body != null ? 'Body: $body' : ''}',
    );
  }

  /// Log API response
  static void logApiResponse({
    required String method,
    required String endpoint,
    required int statusCode,
    dynamic body,
  }) {
    if (statusCode >= 200 && statusCode < 300) {
      info(
        '✅ API Response: $method $endpoint\n'
        'Status: $statusCode\n'
        'Body: $body',
      );
    } else {
      error(
        '❌ API Response: $method $endpoint\n'
        'Status: $statusCode\n'
        'Body: $body',
      );
    }
  }

  /// Log API error
  static void logApiError({
    required String method,
    required String endpoint,
    required dynamic error,
    StackTrace? stackTrace,
  }) {
    error(
      '🚨 API Error: $method $endpoint\n'
      'Error: $error',
      error,
      stackTrace,
    );
  }

  /// Log navigation
  static void logNavigation(String from, String to) {
    debug('🧭 Navigation: $from → $to');
  }

  /// Log state change
  static void logStateChange(String provider, dynamic oldState, dynamic newState) {
    debug('🔄 State Change [$provider]:\n'
        'Old: $oldState\n'
        'New: $newState');
  }

  /// Log function entry (useful for debugging complex flows)
  static void logFunctionEntry(String functionName, [Map<String, dynamic>? args]) {
    debug('🔵 Entering: $functionName${args != null ? '\nArgs: $args' : ''}');
  }

  /// Log function exit (useful for debugging complex flows)
  static void logFunctionExit(String functionName, [dynamic result]) {
    debug('🟢 Exiting: $functionName${result != null ? '\nResult: $result' : ''}');
  }

  /// Log memory/performance warning
  static void logPerformanceWarning(String message) {
    warning('⚠️ Performance: $message');
  }

  /// Log authentication event
  static void logAuthEvent(String event) {
    info('🔐 Auth Event: $event');
  }
}
