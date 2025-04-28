import 'interpreter.dart';
import 'lox_callable.dart';

/// a collection of implementations on the dart side, called from luxx
/// 1) expand a dictionary into a string template

/// lolz, do not need this, as "Interpreter" can call the below method itself
class ExpandString extends LoxCallable {
  @override
  int arity() => 2;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    String string = arguments[0] as String;
    Map<String, Object> map = arguments[1] as Map<String, Object>;

    return expandMapIntoString(string, map);

  }

  @override
  String toString() => '<native> expandString ';
}


/// Dart implementations below

/// todo: room for optimization
/// called by the interpreter, so not really FFI ... TODO: put it somewhere else
String expandMapIntoString(String string, Map<String, Object> map) {
  print (string);
  String result = "";
  for (var it in map.keys) {
    var value = map[it].toString();
    String item = "%{$it}"; // seems I made an regexp pattern, without knowing? Without expanding $it, the line below does not work
    result = string.replaceAll(item, value);
  }
  print (result);
  return result;
}

// in case of string % map, rhs is a LoxInstance
void debugPrintObjects(List objects) {
  print ("debugPrintObjects");
  for (var x in objects)
    print (x);
}

/// for quick tests of the stuff above
main() {

}