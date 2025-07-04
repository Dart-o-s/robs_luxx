import 'dart:collection';
import 'dart:io';
import 'package:luxx_dart/lox_dart.dart';
import 'package:luxx_dart/monitor.dart';
import 'package:path/path.dart' as p;

bool hadError = false;
bool verbose = false;

final interpreter = Interpreter();

void main(List<String> args) {
  List<String> arguments =  [];
  arguments.addAll(args);

  if (!arguments.contains("--no-boot-strap"))
    _bootStrap();
  else
    arguments.remove("--no-boot-strap");

  verbose = arguments.contains("--verbose");
  arguments.remove("--verbose");

  for (var arg in arguments) {
    if (arg == "--eof--") break; // ignore the remaining arguments
    runFile(arg);
  }

  Monitor m = Monitor();
  m.runRepl();

}

void runFile(String filename) {
  var input = File(filename).readAsStringSync();
  if (verbose ) print("running: $filename");
  run(input);
  // if (hadError) print("errors detected");
  // if (interpreter.errors.isNotEmpty) print(70);
  hadError = false;
  interpreter.errors = [];
}

Interpreter run(String input) {
  final scanner = _scanner(input);
  List<Token> tokens = scanner.scan();

  if (scanner.errors.isNotEmpty) {
    for (var err in scanner.errors) {
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

// robertooliveros.cg@outlook.com

Map<String, String> getAllFiles(String directory, String suffix) {
  Directory dir = Directory(directory);
  SplayTreeMap<String, String> res = SplayTreeMap<String, String>();
  for (var entity in dir.listSync(recursive: false, followLinks: false)) {
    if (entity.path.endsWith(suffix)) {
      var base = p.basename(entity.path);
      res[base] = entity.path;
      if (verbose ) print("$base -> ${entity.path}");
    }
  }
  return res;
}

void _bootStrap() {
  // TODO AoS use manifest and really read from assets
  var files = getAllFiles("./assets/luxx_bootstrap", ".luxx");
  var keys = files.keys;
  for (var key in keys) {
    var file = files[key];
    if (file != null )
      runFile(file);
  }
  if (verbose ) print("loaded bootstrap files");
}

// Aos PoI this is nonsense!
Scanner _scanner(String input) {
  return Scanner(input);
}

void error(int line, String where, String message) {
   print('[line $line] Error $where: $message');
}
