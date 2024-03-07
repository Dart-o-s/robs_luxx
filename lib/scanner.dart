import 'package:lox_dart/token.dart';

class Scanner {
  final String input;
  final List<ScanError> errors = [];

  int _pos = 0;

  Scanner(this.input);

  List<Token> scan() {
    List<Token> tokens = [];

    while (peek().isNotEmpty) {
      String current = peek();

      switch (current) {
        case ' ':
        case '\n':
        case '\t':
          advance();
          break;

        case '+':
          tokens.add(Token(type: TokenTypes.plus, lexeme: '+'));
          advance();
          break;

        case '-':
          tokens.add(Token(type: TokenTypes.minus, lexeme: '-'));
          advance();
          break;

        case '*':
          tokens.add(Token(type: TokenTypes.product, lexeme: '*'));
          advance();
          break;

        case '{':
          tokens.add(Token(type: TokenTypes.braceLeft, lexeme: '{'));
          advance();
          break;

        case '}':
          tokens.add(Token(type: TokenTypes.braceRight, lexeme: '}'));
          advance();
          break;

        case '(':
          tokens.add(Token(type: TokenTypes.parenLeft, lexeme: '('));
          advance();
          break;

        case ')':
          tokens.add(Token(type: TokenTypes.parenRight, lexeme: ')'));
          advance();
          break;

        case ';':
          tokens.add(Token(type: TokenTypes.semicolon, lexeme: ';'));
          advance();
          break;

        case '/':
          advance();
          if (peek() == '/') {
            comment();
          } else {
            tokens.add(Token(type: TokenTypes.division, lexeme: '/'));
          }
          break;
      }
    }

    return tokens;
  }

  void comment() {
    do {
      advance();
    } while (!isOutOfRange() && peek() != '\n');
  }

  void advance() {
    _pos++;
  }

  String peek() {
    if (isOutOfRange()) {
      return '';
    } else {
      return input[_pos];
    }
  }

  bool isOutOfRange() {
    return _pos >= input.length;
  }
}

class ScanError extends Error {
  final String description;

  ScanError(this.description);
}
