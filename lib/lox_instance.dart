import 'dart:collection';

import 'package:luxx_dart/lox_dart.dart';

var gInstances = HashSet<LoxInstance>();

class LoxInstance {
  late final LoxClass klass;
  final Map<String, Object?> fields = {};

  LoxInstance(this.klass) {
    gInstances.add(this);
  }

  Object? get(Token name) {
    if (fields.containsKey(name.lexeme)) {
      return fields[name.lexeme];
    }

    LoxFunction? method = klass.findMethod(name.lexeme);
    if (method != null) {
      return method.bind(this);
    }

    throw InterpretError('Undefined property "${name.lexeme}"', name.line);
  }

  void set(String name, Object? value) {
    fields[name] = value;
  }

  @override
  String toString() {
    return '<instance ${klass.name}> {' + fields.toString() + "}";
  }

  Map<dynamic, dynamic> getInstanceAsMap() {
    if (fields.length == 0) return {};
    Object? instance = fields["instance"];
    if (instance !=null ) return instance as Map<dynamic, dynamic>;
    return {};
  }
}
