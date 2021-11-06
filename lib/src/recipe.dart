import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

import 'package:recipe/src/bake_context.dart';
import 'package:recipe/src/framework_entity.dart';
import 'package:recipe/src/ports/ports.dart';
import 'package:recipe/src/utils.dart';

abstract class Recipe with FrameworkEntity, EntityLogging {
  Recipe();

  @mustCallSuper
  @protected
  void initialize() {}

  final Set<InputPort> _inputPorts = {};

  UnmodifiableSetView<InputPort> get inputPorts =>
      UnmodifiableSetView(_inputPorts);

  final Set<OutputPort> _outputPorts = {};

  UnmodifiableSetView<OutputPort> get outputPorts =>
      UnmodifiableSetView(_outputPorts);

  /// Disallows input ports with same label.
  /// TODO: maybe conside disabling this check by overriding global parameters
  @internal
  @protected
  @nonVirtual
  void ensureUniqueInputPortLabel(String label) {
    if (_inputPorts.any((element) => element.name == label)) {
      throw ArgumentError(
        '$runtimeType already has input port with label: $label.',
        'label',
      );
    }
  }

  /// Disallows output ports with same label.
  /// TODO: maybe conside disabling this check by overriding global parameters
  @internal
  @protected
  @nonVirtual
  void ensureUniqueOutputPortLabel(String label) {
    if (_outputPorts.any((element) => element.name == label)) {
      throw ArgumentError(
        '$runtimeType already has output port with label: $label.',
        'label',
      );
    }
  }

  @protected
  @nonVirtual
  @useResult
  SingleInboundInputPort<T> singleInboundInputPort<T extends Object>(
      String label) {
    ensureUniqueInputPortLabel(label);
    final result = SingleInboundInputPort<T>(label);
    _inputPorts.add(result);
    return result;
  }

  @protected
  @nonVirtual
  @useResult
  MultiInboundInputPort<T> inputPort<T extends Object>(String label) {
    ensureUniqueInputPortLabel(label);
    final result = MultiInboundInputPort<T>(label);
    _inputPorts.add(result);
    return result;
  }

  @protected
  @nonVirtual
  @useResult
  OutputPort<T> outputPort<T extends Object>(String label) {
    ensureUniqueOutputPortLabel(label);
    final result = OutputPort<T>(label);
    _outputPorts.add(result);
    return result;
  }

  @mustCallSuper
  @internal
  Future<void> bake(BakeContext context);

  @override
  JsonMap toJson() {
    return {
      ...super.toJson(),
    };
  }
}
