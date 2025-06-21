///
/// The Machine holds the runtime system, scanners token stream, the parsers ast
/// and the loaded classes, functions, and instances
///

import "package:luxx_dart/stmt.dart";
import "package:luxx_dart/token.dart";

import "lox_class.dart";
import "lox_instance.dart";
import "lox_function.dart";

/// todo make weak: https://pub.dev/packages/weak
///
/// Material and Instrument pattern, Machine is the material
/// Monitor and Pagers are the Instruments
class Machine {
  static var gMachine = Machine();

  var functions = gFunctions;
  var classes = gClasses;
  var instances = gInstances;    // TODO, AoS what about GC?
  List<Token>  parserTokens = <Token>[];
  List<Stmt>   stmts = <Stmt>[]; // brauch ich verm. nicht

  Machine(){}
  void setTokens(List<Token>  tokens) {
    parserTokens = tokens;
  }

  void setStatements(List<Stmt> stmts) {
    this.stmts = stmts;
  }

}



