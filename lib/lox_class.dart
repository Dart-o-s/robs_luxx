import 'package:lox_dart/lox_dart.dart';

class LoxClass extends LoxCallable {
  final String name;
  late final List<Fun> methods;

  LoxClass(this.name, this.methods);

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
