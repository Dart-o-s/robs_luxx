import 'package:lox_dart/token.dart';

class Scanner {
  final String input;
  final List<ScanError> errors = [];

  int _pos = 0;
  int line = 1;

  Scanner(this.input);

  List<Token> scan() {
    List<Token> tokens = [];

    while (peek().isNotEmpty) {
      String current = peek();

      switch (current) {
        case ' ':
        case '\t':
          advance();
          break;

        case '\n':
          line++;
          advance();
          break;

        case '+':
          tokens.add(Token(type: TokenType.plus, lexeme: '+', line: line));
          advance();
          break;

        case '-':
          tokens.add(Token(type: TokenType.minus, lexeme: '-', line: line));
          advance();
          break;

        case '*':
          tokens.add(Token(type: TokenType.product, lexeme: '*', line: line));
          advance();
          break;

        case '{':
          tokens.add(Token(type: TokenType.braceLeft, lexeme: '{', line: line));
          advance();
          break;

        case '}':
          tokens
              .add(Token(type: TokenType.braceRight, lexeme: '}', line: line));
          advance();
          break;

        case '(':
          tokens.add(Token(type: TokenType.parenLeft, lexeme: '(', line: line));
          advance();
          break;

        case ')':
          tokens
              .add(Token(type: TokenType.parenRight, lexeme: ')', line: line));
          advance();
          break;

        case ';':
          tokens.add(Token(type: TokenType.semicolon, lexeme: ';', line: line));
          advance();
          break;

        case '/':
          advance();
          if (peek() == '/') {
            comment();
          } else {
            tokens
                .add(Token(type: TokenType.division, lexeme: '/', line: line));
          }
          break;

        case '<':
          advance();
          if (peek() == '=') {
            advance();
            tokens.add(
                Token(type: TokenType.lessEqual, lexeme: '<=', line: line));
          } else {
            tokens.add(Token(type: TokenType.less, lexeme: '<', line: line));
          }
          break;

        case '>':
          advance();
          if (peek() == '=') {
            tokens.add(
                Token(type: TokenType.greaterEqual, lexeme: '>=', line: line));
            advance();
          } else {
            tokens.add(Token(type: TokenType.greater, lexeme: '>', line: line));
          }
          break;

        case '=':
          advance();
          if (peek() == '=') {
            tokens.add(
                Token(type: TokenType.equalEqual, lexeme: '==', line: line));
            advance();
          } else {
            tokens.add(Token(type: TokenType.equal, lexeme: '=', line: line));
          }
          break;

        case '!':
          advance();
          if (peek() == '=') {
            tokens.add(
                Token(type: TokenType.bangEqual, lexeme: '!=', line: line));
            advance();
          } else {
            tokens.add(Token(type: TokenType.bang, lexeme: '!', line: line));
          }
          break;

        case '"':
          tokens.add(string());
          advance();
          break;

        default:
          if (isNumeric()) {
            tokens.add(number());
          } else if (isAlphaNumeric()) {
            tokens.add(identifier());
          }
      }
    }

    tokens.add(Token(type: TokenType.eof, lexeme: '', line: line));
    return tokens;
  }

  void comment() {
    do {
      advance();
    } while (peek().isNotEmpty && peek() != '\n');
  }

  Token string() {
    advance();

    String value = '';
    while (peek().isNotEmpty && peek() != '"') {
      value += peek();
      advance();
    }

    if (peek().isEmpty) {
      errors.add(ScanError('Closing \'"\' expected.'));
    }

    return Token(
        type: TokenType.string, lexeme: '"$value"', value: value, line: line);
  }

  Token number() {
    String value = '';
    bool hasDecimal = false;

    do {
      value += peek();
      advance();

      if (!isNumeric()) {
        if (peek() == '.' && !hasDecimal) {
          hasDecimal = true;
        } else if (peek() == ".") {
          errors.add(ScanError('Unexpected decimal point found.'));
          advance();
        } else {
          break;
        }
      }
    } while (peek().isNotEmpty);

    return Token(
        type: TokenType.number, lexeme: value, value: value, line: line);
  }

  Token identifier() {
    String value = '';

    do {
      value += peek();
      advance();
    } while (peek().isNotEmpty && isAlphaNumeric());

    TokenType? type = getKeyword(value);
    type ??= TokenType.identifier;

    return Token(type: type, lexeme: value, value: value, line: line);
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

  bool isNumeric() {
    return int.tryParse(peek()) != null;
  }

  bool isAlphaNumeric() {
    final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumeric.hasMatch(peek());
  }

  TokenType? getKeyword(String value) {
    Iterable<TokenType> results = TokenType.values
        .where((element) => element.name.substring(0, 2) == 'kw')
        .where((element) => element.name.substring(2).toLowerCase() == value);

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }
}

class ScanError extends Error {
  final String description;

  ScanError(this.description);
}
