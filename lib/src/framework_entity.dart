import 'package:meta/meta.dart';
import 'package:fhir_yaml/fhir_yaml.dart';

import 'package:recipe/src/utils.dart';

mixin FrameworkEntity {
  String get name => runtimeType.toString();

  @mustCallSuper
  JsonMap toJson() {
    return {
      'name': name,
      'runtime type': runtimeType.toString(),
      'ref': hashCode,
    };
  }

  @nonVirtual
  String toYaml() => json2yaml(toJson());

  // @protected
  // @mustCallSuper
  // bool register() {
  //   final entity = this;

  //   if (entity is Recipe) {
  //     verbose('registering as recipe');
  //     return SketchRegistry.recipes.add(entity);
  //   }

  //   if (entity is Port) {
  //     verbose('registering as port');
  //     return SketchRegistry.ports.add(entity);
  //   }

  //   if (entity is Connection) {
  //     verbose('registering as connection');
  //     return SketchRegistry.connections.add(entity);
  //   }

  //   throw UnsupportedError(
  //       '${this.runtimeType} is not a supported type that can be registered.');
  // }

  @override
  String toString() => '$runtimeType';
}

mixin EntityLogging on FrameworkEntity {
  static bool _shouldIncludeHash = false;

  static showHashCodeOfEntities() => _shouldIncludeHash = true;
  static hideHashCodeOfEntities() => _shouldIncludeHash = false;

  @protected
  void log(String message, {LogLevel level = LogLevels.info}) {
    final moduleName = _shouldIncludeHash ? '$name#$hashCode' : name;

    FrameworkUtils.log(message, module: moduleName, level: level);
  }

  @protected
  void warn(String message) => log(message, level: LogLevels.warning);

  @protected
  void error(String message) => log(message, level: LogLevels.error);

  @protected
  void info(String message) => log(message, level: LogLevels.info);

  @protected
  void verbose(String message) => log(message, level: LogLevels.verbose);
}
