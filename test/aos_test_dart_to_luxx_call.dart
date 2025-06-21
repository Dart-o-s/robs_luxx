/*
   we want to sent some event to the current interpreter in gInterpreter
   But actually, we know nothing about the interpreter, we know only the
   globals in luxx_dfi.dart! And that is enough.
 */
import 'package:luxx_dart/interpreter.dart';
import 'package:luxx_dart/luxx_dfi.dart';

void main() {
  // oops, we had to initialize one ... or the globals in interpreter.dart are
  // not initialized ... strange

  Interpreter();
  var call1 = ["object", "method", "arg1", "args"];
  var call2 = ["function1", "f-arg1", "f-arg2"];

  // first call to luxx will have two arguments
  gLuxxy.add(call1);
  gLuxxy.add(call2);
  luxx();

  var call3 = ["this", "is", "just", "an", "event"];
  gLuxxy.add(call3);
  luxx();

}