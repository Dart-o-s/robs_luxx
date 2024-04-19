import 'package:lox_dart/lox_dart.dart';

class LoxInstance {
  late final LoxClass klass;
  final Map<String, Object?> fields = {};

  LoxInstance(this.klass);

  Object? get(Token name) {
    if (fields.containsKey(name.lexeme)) {
      return fields[name.lexeme];
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
