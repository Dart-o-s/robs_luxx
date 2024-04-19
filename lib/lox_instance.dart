import 'package:lox_dart/lox_dart.dart';
import 'package:lox_dart/lox_function.dart';

class LoxInstance {
  late final LoxClass klass;
  final Map<String, Object?> fields = {};

  LoxInstance(this.klass);

  Object? get(Token name) {
    if (fields.containsKey(name.lexeme)) {
      return fields[name.lexeme];
    }

    LoxFunction? method = klass.findMethod(name.lexeme);
    if (method != null) {
      return method;
    }

    throw InterpretError('Undefined property "${name.lexeme}"', name.line);
  }

  void set(String name, Object? value) {
    fields[name] = value;
  }

  @override
  String toString() {
    return '<instance ${klass.name}>';
  }
}
