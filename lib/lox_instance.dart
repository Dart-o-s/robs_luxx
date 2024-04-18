import 'package:lox_dart/lox_dart.dart';

class LoxInstance {
  late final LoxClass klass;

  LoxInstance(this.klass);

  @override
  String toString() {
    return '<instance ${klass.name}>';
  }
}
