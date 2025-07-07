import 'package:luxx_dart/lox_dart.dart';

/*
  globals.define('createArray', ArrayCreate());
  globals.define('lengthArray', ArrayLength());
  globals.define('addArray', ArrayAdd()); // TODO AoS perhaps a candidate for "+"
  globals.define('ArraySetAt', ArraySet());
  globals.define('ArrayGetAt', ArrayGet());
 */

// TODO aos think about initial size or clamped arrays
class ArrayCreate extends LoxCallable {
  @override
  int arity() => 0;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    return [];
  }

  @override
  String toString() => '<native> Array Create ';
}

//
class ArrayLength extends LoxCallable {
  @override
  int arity() => 1;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    Object? array = arguments[0];

    if (array != null) {
      List list = array as List;
      return list.length;
    }

    return -1; // error array does not exist
  }

  @override
  String toString() => '<native> Array Length ';
}
class ArrayAdd extends LoxCallable {
  @override
  int arity() => 2;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    Object? array = arguments[0];

    if (array != null) {
      List list = array as List;
      Object? obj = arguments[1];
      list.add(obj);
      return array;
    }

    return -1; // error array does not exist
  }

  @override
  String toString() => '<native> Array Add ';
}
class ArraySet extends LoxCallable {
  @override
  int arity() => 3;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    Object? array = arguments[0];

    if (array != null) {
      List list = array as List;
      Object? item = arguments[1];
      Object? idx_ = arguments[2];
      if (idx_ != null) {
        double idx = idx_ as double;
        list[idx.toInt()] = item;
        return array;
      }
      return array; // aos is that smart when the index was null?
    }

    return -1; // error array does not exist
  }

  @override
  String toString() => '<native> Array Set ';
}
class ArrayGet extends LoxCallable {
  @override
  int arity() => 2;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    Object? array = arguments[0];

    if (array != null) {
      List list = array as List;
      Object? idx_ = arguments[1];
      if (idx_ != null) {
        double idx = idx_ as double;
        return list[idx.toInt()];
      }
      return null;
    }
    return -1; // aos error array does not exist, we need to do better
  }

  @override
  String toString() => '<native> Array Get ';
}

