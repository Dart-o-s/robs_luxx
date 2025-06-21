import 'package:luxx_dart/lox_dart.dart';
import 'luxx_dfi.dart';

class Clock extends LoxCallable {
  @override
  int arity() => 0;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String toString() => '<native fn>, call to: DateTime.now().millisecondsSinceEpoch';
}

// funny name, no one sees it, as it is only the class name
// we put an instance of this one into the rEnvironment
class Darcy extends LoxCallable {
  @override
  int arity() {
    return 1;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    gDarcy.add(arguments);
  }
}

// call the dart side, to process the queue/list
class ThrowTheDart extends LoxCallable {
  @override
  int arity() {
    return 0;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    // call the global function dart, which hopefully was set on the dart side :D
    dart();
  }

}
