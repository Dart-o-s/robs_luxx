import 'dart:io';
import 'package:lox_dart/ast_printer.dart';
import 'package:lox_dart/lox_dart.dart';
import 'package:lox_dart/parser.dart';

bool hadError = false;

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
  final parser = Parser(tokens);
  Expr expression = parser.parse();

  print(AstPrinter().print(expression));

  if (scanner.errors.isNotEmpty) {
    hadError = true;

    for (var error in scanner.errors) {
      print(error.description);
    }
  }

  if (!hadError && parser.errors.isNotEmpty) {
    for (var error in parser.errors) {
      print(error.description);
    }
  }

  if (hadError) exit(65);
}

void error(int line, String where, String message) {
  print('[line $line] Error $where: $message');
  hadError = true;
}
