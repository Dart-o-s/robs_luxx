///
/// a) scan the script/luxx file
/// b) do we add it right away to the existing tokens?
/// c) when do we parse it?
///
/// Goal is to end finally with an interpreted script, right?
///

import 'dart:io';
import 'dart:collection';
import 'package:path/path.dart' as p;

import '../scanner.dart';
import '../token.dart';

import 'package:lox_dart/lox_dart.dart';
import 'package:lox_dart/interpreter.dart';
import 'package:lox_dart/monitor.dart';

///
/// Load a source file and scan it
/// make a new scanner
/// append the tokens to the existing tokens
///
/// This is done by the interpreter, so there
/// should be no problem with the existing code
///
bool hadError = false;
final interpreter = Interpreter();

class LoadScript {
  final String filename;
  late final List<Token> tokens;
  bool hadError = false;
  late Scanner _scanner;
  late String _input;

  LoadScript(this.filename) {
    _input = File(filename).readAsStringSync();
    _scanner = Scanner(_input);
  }

  void load() {
    print("running: $filename");
    // here we have to add the loaded tokens
    // and the statements to the VM

    var interpreter = run(_input);
  }

  /// copied from aos_start_lux.dart

  Interpreter run(String input) {
    List<Token> tokens = _scanner.scan();

    if (_scanner.errors.isNotEmpty) {
      for (var err in _scanner.errors) {
        error(err.line, '', err.description);
      }

      hadError = true;
      return interpreter;
    }

    final parser = Parser(tokens);
    List<Stmt> statements = parser.parse();

    if (parser.errors.isNotEmpty) {
      for (var err in parser.errors) {
        error(err.line, '', err.description);
      }

      hadError = true;
      return interpreter;
    }

    final resolver = Resolver(interpreter);
    resolver.resolve(statements);

    if (resolver.errors.isNotEmpty) {
      for (var err in resolver.errors) {
        error(err.line, '', err.description);
      }

      hadError = true;
      return interpreter;
    }

    interpreter.interpret(statements);

    if (interpreter.errors.isNotEmpty) {
      for (var err in interpreter.errors) {
        error(err.line, '', err.description);
      }
    }
    return interpreter;
  }

  void error(int line, String where, String message) {
    print('[line $line] Error $where: $message');
  }

}