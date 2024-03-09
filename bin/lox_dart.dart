import 'dart:io';
import 'package:lox_dart/lox_dart.dart';

void main(List<String> arguments) {
  if (arguments.length > 1) {
    stdout.writeln('Usage: dart run lox_dart [file]');
    exit(64);
  } else if (arguments.length == 1) {
    runFile(arguments[0]);
  } else {
    runRepl();
  }
}

void runRepl() {
  stdout.write('> ');
  var input = stdin.readLineSync();

  while (input != null) {
    run(input);
    stdout.write('> ');
    input = stdin.readLineSync();
  }
}

void runFile(String filename) {
  File(filename).readAsString().then((input) {
    run(input);
  });
}

void run(String input) {
  final scanner = Scanner(input);
  List<Token> tokens = scanner.scan();

  if (scanner.errors.isNotEmpty) {
    for (var err in scanner.errors) {
      error(err.line, '', err.description);
    }

    exit(65);
  }

  final parser = Parser(tokens);
  Expr? expression = parser.parse();

  if (parser.errors.isNotEmpty) {
    for (var err in parser.errors) {
      error(err.line, '', err.description);
    }

    exit(65);
  }

  print(AstPrinter().print(expression!));

  final interpreter = Interpreter();
  interpreter.interpret(expression);

  if (interpreter.errors.isNotEmpty) {
    for (var err in interpreter.errors) {
      error(err.line, '', err.description);
    }

    exit(65);
  }
}

void error(int line, String where, String message) {
  print('[line $line] Error $where: $message');
}
