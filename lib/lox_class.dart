import 'package:lox_dart/lox_dart.dart';

class LoxClass extends LoxCallable {
  final String name;
  LoxClass? superclass;
  late final Map<String, LoxFunction> methods;

  LoxClass(this.name, this.superclass, this.methods);

  LoxFunction? findMethod(String name) {
    if (methods.containsKey(name)) {
      return methods[name];
    }

    return superclass?.findMethod(name);
  }

  @override
  int arity() {
    LoxFunction? init = findMethod('init');
    if (init != null) {
      return init.arity();
    } else {
      return 0;
    }
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    LoxInstance instance = LoxInstance(this);
    LoxFunction? init = findMethod('init');
    if (init != null) {
      init.bind(instance).call(interpreter, arguments);
    }
    return instance;
  }

  @override
  String toString() {
    return '<class $name>';
  }
}
