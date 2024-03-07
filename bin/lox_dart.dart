import 'dart:io';
import 'package:lox_dart/lox_dart.dart';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    runLine();
  } else {
    run(arguments[0]);
  }
}

void runLine() {
  stdout.write('> ');
  var input = stdin.readLineSync();

  while (input != null) {
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

    stdout.write('> ');
    input = stdin.readLineSync();
  }
}

void run(String filename) {
  File(filename).readAsString().then((input) {
    final scanner = Scanner(input);
    List<Token> tokens = scanner.scan();
    for (var token in tokens) {
      print(token);
    }
  });
}
