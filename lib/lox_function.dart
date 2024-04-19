import 'package:lox_dart/lox_dart.dart';

class LoxFunction extends LoxCallable {
  final Fun declaration;
  final Environment closure;

  LoxFunction(this.declaration, this.closure);

  @override
  int arity() => declaration.params.length;

  LoxFunction bind(LoxInstance instance) {
    Environment environment = Environment(closure);
    environment.define("this", instance);
    return LoxFunction(declaration, environment);
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    Environment environment = Environment(closure);

    for (int i = 0; i < declaration.params.length; i++) {
      environment.define(declaration.params[i].lexeme, arguments[i]);
    }

    try {
      interpreter.executeBlock(declaration.body, environment);
    } catch (e) {
      if (e is ReturnException) {
        return e.value;
      } else {
        rethrow;
      }
    }

    return null;
  }

  @override
  String toString() => '<fn ${declaration.name.lexeme}>';
}
