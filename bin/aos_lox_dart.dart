import 'dart:io';
import 'package:lox_dart/lox_dart.dart';

bool hadError = false;
final interpreter = Interpreter();

void main(List<String> arguments) {
  for (var arg in arguments) {
    runFile(arg);
  }
  // runRepl();
}

void runRepl() {
  stdout.write('> ');
  var input = stdin.readLineSync();

  while (input != null) {
    if (input == "exit")
      exit(0);

    run(input);
    stdout.write('> ');
    input = stdin.readLineSync();

    hadError = false;
    interpreter.errors = [];
  }
}

void runFile(String filename) {
  var input = File(filename).readAsStringSync();
  print("running: $filename");
  run(input);
  // if (hadError) print("errors detected");
  // if (interpreter.errors.isNotEmpty) print(70);
  hadError = false;
  interpreter.errors = [];
}

Interpreter run(String input) {
  final scanner = Scanner(input);
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

void error(int line, String where, String message) {
  print('[line $line] Error $where: $message');
}
