import 'package:lox_dart/lox_dart.dart';

class LoxClass {
  final String name;
  late final List<Fun> methods;

  LoxClass(this.name, this.methods);

  @override
  String toString() {
    return '<class $name>';
  }
}
