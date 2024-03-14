import 'package:lox_dart/lox_dart.dart';

class Clock extends LoxCallable {
  @override
  int arity() => 0;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String toString() => '<native fn>';
}
