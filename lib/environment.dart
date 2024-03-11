import 'package:lox_dart/lox_dart.dart';

class Environment {
  final Map<String, Object?> vars = {};

  void define(String key, Object? value) {
    vars[key] = value;
  }

  Object? get(Token name) {
    if (vars.containsKey(name.lexeme)) {
      return vars[name.lexeme];
    }

    throw InterpretError('Undefined variable "${name.lexeme}".', name.line);
  }

  void assign(Token name, Object? value) {
    if (vars.containsKey(name.lexeme)) {
      vars[name.lexeme] = value;
    } else {
      throw InterpretError('Undefined variable "${name.lexeme}".', name.line);      
    }
  }
}
