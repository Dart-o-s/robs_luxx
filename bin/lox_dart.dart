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
  for (var token in tokens) {
    print(token);
  }

  if (scanner.errors.isNotEmpty) {
    for (var error in scanner.errors) {
      print(error.description);
    }
  }
}
