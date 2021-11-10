import 'dart:io';

import 'package:meta/meta.dart';
import 'package:tint/tint.dart';

import 'framework_entity.dart';

@doNotStore
class Log {
  factory Log(
    final Object? object, {
    required final LogLevel level,
    final FrameworkEntity module = anonymous,
    final LogOptions? logOptions,
  }) =>
      Log._(level, module, object, logOptions);

  Log._(
    final this.level,
    final this.module,
    final this.object,
    final LogOptions? _logOptions,
  )   : logOptions = _logOptions ?? Log.defaultOptions,
        shouldBeep = level == LogLevels.fatal {
    // Skip remaining if it's not going to be logged.
    if (level.value < Log.loggingLevel.value) return;

    if (shouldBeep) stdout.writeCharCode(0x07);

    // TODO : format and print the message
  }

  factory Log.fatal(
    final Object? object, {
    final FrameworkEntity module = anonymous,
    final LogOptions? logOptions,
  }) =>
      Log._(LogLevels.fatal, module, object, logOptions);

  factory Log.error(
    final Object? object, {
    final FrameworkEntity module = anonymous,
    final LogOptions? logOptions,
  }) =>
      Log._(LogLevels.error, module, object, logOptions);

  factory Log.warn(
    final Object? object, {
    final FrameworkEntity module = anonymous,
    final LogOptions? logOptions,
  }) =>
      Log._(LogLevels.warning, module, object, logOptions);

  factory Log.info(
    final Object? object, {
    final FrameworkEntity module = anonymous,
    final LogOptions? logOptions,
  }) =>
      Log._(LogLevels.info, module, object, logOptions);

  factory Log.verbose(
    final Object? object, {
    final FrameworkEntity module = anonymous,
    final LogOptions? logOptions,
  }) =>
      Log._(LogLevels.verbose, module, object, logOptions);

  factory Log.trace(
    final Object? object, {
    final FrameworkEntity module = anonymous,
    final LogOptions? logOptions,
  }) =>
      Log._(LogLevels.trace, module, object, logOptions);

  static LogOptions defaultOptions = LogOptions.defaults();
  static LogLevel loggingLevel = LogLevels.info;

  final Object? object;
  final FrameworkEntity module;
  final LogLevel level;
  final LogOptions logOptions;
  final bool shouldBeep;
}

@immutable
class LogOptions {
  const LogOptions({
    final this.includeTimestamps = true,
    final this.applyColors = true,
  });

  const factory LogOptions.defaults() = LogOptions;

  final bool includeTimestamps;

  final bool applyColors;

  LogOptions copyWith({
    final bool? includeTimestamps,
    final bool? applyColors,
  }) {
    return LogOptions(
      includeTimestamps: includeTimestamps ?? this.includeTimestamps,
      applyColors: applyColors ?? this.applyColors,
    );
  }
}

class _AnonymousModule with FrameworkEntity {
  const _AnonymousModule(this.name);

  @override
  final String name;
}

const anonymous = _AnonymousModule('Anonymous');

/// Log level that is used for logging.
///
/// See [LogLevels] for all available levels.
@immutable
class LogLevel implements Comparable<LogLevel> {
  @literal
  const LogLevel({
    required final this.label,
    required final this.labelAsSymbol,
    required final this.value,
    required final this.moduleNameFormatter,
    required final this.messageFormatter,
  });

  /// A value to compare between all [LogLevels].
  final int value;

  /// The short symbolic representation of [label].
  final String labelAsSymbol;

  /// The name of this [LogLevel].
  final String label;

  final String Function(FrameworkEntity module) moduleNameFormatter;

  final String Function(Object? object) messageFormatter;

  @override
  int compareTo(final LogLevel other) => value.compareTo(other.value);

  @override
  String toString() => label.strip();
}

/// All available [LogLevel]s as static members.
///
/// This class is not intended to be used as a super class nor be instantiated.
@sealed
abstract class LogLevels {
  /// The log level that disables logging. Use this level only for setting
  /// logging level.
  /// TODO: improve docs
  static const off = LogLevel(
    label: 'off',
    labelAsSymbol: 'OFF',
    value: 100,
    moduleNameFormatter: _cannotFormat,
    messageFormatter: _cannotFormat,
  );

  /// Log level to log fatal events.
  static const fatal = LogLevel(
    label: _fatalLabel,
    labelAsSymbol: _fatalSymbolicLabel,
    value: 80,
    moduleNameFormatter: _noFormatting,
    messageFormatter: _fatalMessageFormatter,
  );

  /// Log level to log errors.
  static const error = LogLevel(
    label: _errorLabel,
    labelAsSymbol: _errorSymbolicLabel,
    value: 70,
    moduleNameFormatter: _noFormatting,
    messageFormatter: _errorMessageFormatter,
  );

  /// Log level to log warnings.
  static const warning = LogLevel(
    label: _warningLabel,
    labelAsSymbol: _warningSymbolicLabel,
    value: 60,
    moduleNameFormatter: _noFormatting,
    messageFormatter: _warningMessageFormatter,
  );

  /// Log level to log successful events.
  static const success = LogLevel(
    label: _successLabel,
    labelAsSymbol: _successSymbolicLabel,
    value: 60,
    moduleNameFormatter: _noFormatting,
    messageFormatter: _successMessageFormatter,
  );

  /// Log level to log infos.
  static const info = LogLevel(
    label: _infoLabel,
    labelAsSymbol: _infoSymbolicLabel,
    value: 40,
    moduleNameFormatter: _noFormatting,
    messageFormatter: _noFormatting,
  );

  /// Log level to log verbose events.
  static const verbose = LogLevel(
    label: _verboseLabel,
    labelAsSymbol: _verboseSymbolicLabel,
    value: 20,
    moduleNameFormatter: _noFormatting,
    messageFormatter: _verboseFormatting,
  );

  /// Log level to trace events. Use this level to report that you inhaled and
  /// exhaled.
  static const trace = LogLevel(
    label: _traceLabel,
    labelAsSymbol: _traceSymbolicLabel,
    value: 10,
    moduleNameFormatter: _noFormatting,
    messageFormatter: _traceFormatting,
  );

  /// The log level that enables all levels to be logged. Use this level only
  /// for setting logging level.
  static const all = LogLevel(
    label: 'all',
    labelAsSymbol: 'ALL',
    value: 0,
    moduleNameFormatter: _cannotFormat,
    messageFormatter: _cannotFormat,
  );

  /// All available valid [LogLevel]s in this framework.
  static const values = [
    fatal,
    error,
    warning,
    success,
    info,
    verbose,
    trace,
  ];

  /// Obtained by the following:
  ///
  /// ```dart
  /// jsonEncode(' FATAL '.bold().brightRed().blink().reset());
  /// ```
  static const _fatalLabel =
      "\u001b[0m\u001b[5m\u001b[91m\u001b[1m  FATAL\u001b[22m\u001b[39m\u001b[25m\u001b[0m";

  /// Obtained by the following:
  ///
  /// ```dart
  /// jsonEncode(' ✘ '.brightRed().blink().reset());
  /// ```
  static const _fatalSymbolicLabel =
      "\u001b[0m\u001b[5m\u001b[91m ✘\u001b[39m\u001b[25m\u001b[0m";

  /// Obtained by the following:
  ///
  /// ```dart
  /// jsonEncode(' error '.red().reset());
  /// ```
  static const _errorLabel = "\u001b[0m\u001b[31m  error\u001b[39m\u001b[0m";

  /// Obtained by the following:
  ///
  /// ```dart
  /// jsonEncode(' ✗ '.brightRed().reset());
  /// ```
  static const _errorSymbolicLabel = "\u001b[0m\u001b[91m ✗\u001b[39m\u001b[0m";

  /// Obtained by the following:
  ///
  /// ```dart
  /// jsonEncode(' warning '.brightYellow().reset());
  /// ```
  static const _warningLabel = "\u001b[0m\u001b[93mwarning\u001b[39m\u001b[0m";

  /// Obtained by the following:
  ///
  /// ```dart
  /// jsonEncode('[!]'.brightYellow().reset());
  /// ```
  static const _warningSymbolicLabel =
      "\u001b[0m\u001b[93m !\u001b[39m\u001b[0m";

  /// Obtained by the following:
  ///
  /// ```dart
  /// jsonEncode(' success '.brightGreen().reset());
  /// ```
  static const _successLabel = "\u001b[0m\u001b[92msuccess\u001b[39m\u001b[0m";

  /// Obtained by the following:
  ///
  /// ```dart
  /// jsonEncode(' ✔ '.brightGreen().reset());
  /// ```
  static const _successSymbolicLabel =
      "\u001b[0m\u001b[92m ✔\u001b[39m\u001b[0m";

  /// Obtained by the following:
  ///
  /// ```dart
  /// jsonEncode(' info '.brightCyan().reset());
  /// ```
  static const _infoLabel = "\u001b[0m\u001b[96m   info\u001b[39m\u001b[0m";

  /// Obtained by the following:
  ///
  /// ```dart
  /// jsonEncode(' i '.italic().bold().brightCyan().reset());
  /// ```
  static const _infoSymbolicLabel =
      "\u001b[0m\u001b[96m\u001b[1m\u001b[3m i\u001b[23m\u001b[22m\u001b[39m\u001b[0m";

  /// Obtained by the following:
  ///
  /// ```dart
  /// jsonEncode(' info '.brightCyan().reset());
  /// ```
  static const _verboseLabel = "\u001b[0m\u001b[2mverbose\u001b[22m\u001b[0m";

  /// Obtained by the following:
  ///
  /// ```dart
  /// jsonEncode(' v '.dim().reset());
  /// ```
  static const _verboseSymbolicLabel =
      "\u001b[0m\u001b[2m v\u001b[22m\u001b[0m";

  /// Obtained by the following:
  ///
  /// ```dart
  /// jsonEncode(' trace '.dim().reset());
  /// ```
  static const _traceLabel = "\u001b[0m\u001b[2m  trace\u001b[22m\u001b[0m";

  /// Obtained by the following:
  ///
  /// ```dart
  /// jsonEncode('   ');
  /// ```
  static const _traceSymbolicLabel = "  ";

  /// This formatter does not allow formatting to occur and throws
  /// [UnimplementedError] when invoked.
  ///
  /// Used by [LogLevels.all] and [LogLevels.off] which is not intended to be
  /// used as a level in a log event.
  @alwaysThrows
  static String _cannotFormat(final Object? _) => throw UnimplementedError();

  /// Applies no formatting to [object.toString].
  static String _noFormatting(final Object? object) =>
      object.toString().reset();

  /// Formats the result of [object.toString] as per fatal message style.
  ///
  /// See implementation for exact styles applied.
  static String _fatalMessageFormatter(final Object? object) =>
      object.toString().red().bold().reset();

  /// Formats the result of [object.toString] as per error message style.
  ///
  /// See implementation for exact styles applied.
  static String _errorMessageFormatter(final Object? object) =>
      object.toString().red().reset();

  /// Formats the result of [object.toString] as per warning message style.
  ///
  /// See implementation for exact styles applied.
  static String _warningMessageFormatter(final Object? object) =>
      object.toString().brightYellow().reset();

  /// Formats the result of [object.toString] as per success message style.
  ///
  /// See implementation for exact styles applied.
  static String _successMessageFormatter(final Object? object) =>
      object.toString().brightGreen().reset();

  /// Formats the result of [object.toString] as per verbose message style.
  ///
  /// See implementation for exact styles applied.
  static String _verboseFormatting(final Object? object) =>
      object.toString().dim().reset();

  /// Formats the result of [object.toString] as per trace message style.
  ///
  /// See implementation for exact styles applied.
  static String _traceFormatting(final Object? object) =>
      object.toString().dim().italic().reset();
}
