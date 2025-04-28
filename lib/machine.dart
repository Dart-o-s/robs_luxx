///
/// The Machine holds the runtime system, scanners token stream, the parsers ast
/// and the loaded classes, functions, and instances
///
import "dart:collection";

import "package:lox_dart/stmt.dart";
import "package:lox_dart/token.dart";

import "lox_class.dart";
import "lox_instance.dart";
import "lox_function.dart";

/// todo make weak: https://pub.dev/packages/weak
///
/// Material and Instrument pattern, Machine is the material
///
class Machine {
  static var gMachine = Machine();

  var functions = gFunctions;
  var classes = gClasses;
  var instances = gInstances; // TODO, AoS what about GC?
  List<Token>  parserTokens = <Token>[];
  List<Stmt>   stmts = <Stmt>[];

  Machine(){}
  void setTokens(List<Token>  tokens) {
    parserTokens = tokens;
  }

  void setStatements(List<Stmt> stmts) {
    this.stmts = stmts;
  }

}



