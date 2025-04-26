import 'package:lox_dart/lox_dart.dart';

// TODO aos think about initial size or clamped maps
class MapCreate extends LoxCallable {
  @override
  int arity() => 0;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    return {};
  }

  @override
  String toString() => '<native> Map Create ';
}
class MapLength extends LoxCallable {
  @override
  int arity() => 1;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    Object? map = arguments[0];

    if (map != null) {
      Map cont = map as Map;
      return cont.length;
    }

    return -1; // error map does not exist
  }

  @override
  String toString() => '<native> Map Length ';
}
class MapSet extends LoxCallable {
  @override
  int arity() => 3;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    Object? map = arguments[0];

    if (map != null) {
      Map cont = map as Map;
      Object? idx = arguments[1];
      Object? item = arguments[2];
      if (idx != null)
        cont[idx] = item;
      return map;
    }

    return -1; // error map does not exist
  }

  @override
  String toString() => '<native> Map Set ';
}
class MapGet extends LoxCallable {
  @override
  int arity() => 2;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    Object? map = arguments[0];

    if (map != null) {
      Map cont = map as Map;
      Object? idx = arguments[1];
      if (idx != null) {
        return cont[idx];
      }
      return null;
    }
    return -1; // aos error map does not exist, we need to do better
  }

  @override
  String toString() => '<native> Map Get ';
}

