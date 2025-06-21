import 'package:luxx_dart/lox_dart.dart';

abstract class LoxCallable {
  int arity();
  Object? call(Interpreter interpreter, List<Object?> arguments);
}
