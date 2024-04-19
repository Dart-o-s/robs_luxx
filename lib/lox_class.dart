import 'package:lox_dart/lox_dart.dart';

class LoxClass extends LoxCallable {
  final String name;
  late final Map<String, LoxFunction> methods;

  LoxClass(this.name, this.methods);

  LoxFunction? findMethod(String name) {
    return methods[name];
  }

  @override
  int arity() {
    return 0;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    return LoxInstance(this);
  }

  @override
  String toString() {
    return '<class $name>';
  }
}
