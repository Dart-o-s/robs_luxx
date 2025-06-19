import 'dart:collection';

import 'package:lox_dart/lox_dart.dart';

var gFunctions = HashSet<LoxFunction>();

class LoxFunction extends LoxCallable {
  final Fun declaration;
  final Environment closure;
  final bool isInitializer;

  LoxFunction(this.declaration, this.closure, this.isInitializer) {
    gFunctions.add(this);
  }

  @override
  int arity() => declaration.params.length;

  LoxFunction bind(LoxInstance instance) {
    Environment environment = Environment(closure);
    environment.define("this", instance);
    return LoxFunction(declaration, environment, isInitializer);
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    Environment environment = Environment(closure);

    for (int i = 0; i < declaration.params.length; i++) {
      environment.define(declaration.params[i].lexeme, arguments[i]);
    }

    try { // HERE AoS
      if (interpreter.executeRequireConstraints(declaration.contract, environment))

        interpreter.executeBlock(declaration.body, environment);

        interpreter.executeEnsureConstraints(declaration.contract, environment);
        interpreter.executeInvariantConstraints(declaration.contract, environment);

    } catch (e) {
      if (e is ReturnException) {
        interpreter.executeEnsureConstraints(declaration.contract, environment);
        interpreter.executeInvariantConstraints(declaration.contract, environment);
        if (isInitializer) {  // in theory an init() could() ensure something
          return closure.getAt(0, 'this');
        } else {
          return e.value;
        }
      } else {
        rethrow;
      }
    }

    if (isInitializer) {
      return closure.getAt(0, 'this');
    }

    return null;
  }

  @override
  String toString() => '<fn ${declaration.name.lexeme}>';
}
