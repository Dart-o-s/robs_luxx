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
          tokens.add(Token(type: TokenTypes.plus, lexeme: '+', line: line));
          advance();
          break;

        case '-':
          tokens.add(Token(type: TokenTypes.minus, lexeme: '-', line: line));
          advance();
          break;

        case '*':
          tokens.add(Token(type: TokenTypes.product, lexeme: '*', line: line));
          advance();
          break;

        case '{':
          tokens
              .add(Token(type: TokenTypes.braceLeft, lexeme: '{', line: line));
          advance();
          break;

        case '}':
          tokens
              .add(Token(type: TokenTypes.braceRight, lexeme: '}', line: line));
          advance();
          break;

        case '(':
          tokens
              .add(Token(type: TokenTypes.parenLeft, lexeme: '(', line: line));
          advance();
          break;

        case ')':
          tokens
              .add(Token(type: TokenTypes.parenRight, lexeme: ')', line: line));
          advance();
          break;

        case ';':
          tokens
              .add(Token(type: TokenTypes.semicolon, lexeme: ';', line: line));
          advance();
          break;

        case '/':
          advance();
          if (peek() == '/') {
            comment();
          } else {
            tokens
                .add(Token(type: TokenTypes.division, lexeme: '/', line: line));
          }
          break;

        case '<':
          advance();
          if (peek() == '=') {
            advance();
            tokens.add(
                Token(type: TokenTypes.lessEqual, lexeme: '<=', line: line));
          } else {
            tokens.add(Token(type: TokenTypes.less, lexeme: '<', line: line));
          }
          break;

        case '>':
          advance();
          if (peek() == '=') {
            tokens.add(
                Token(type: TokenTypes.greaterEqual, lexeme: '>=', line: line));
            advance();
          } else {
            tokens
                .add(Token(type: TokenTypes.greater, lexeme: '>', line: line));
          }
          break;

        case '=':
          advance();
          if (peek() == '=') {
            tokens.add(
                Token(type: TokenTypes.equalEqual, lexeme: '==', line: line));
            advance();
          } else {
            tokens.add(Token(type: TokenTypes.equal, lexeme: '=', line: line));
          }
          break;

        case '!':
          advance();
          if (peek() == '=') {
            tokens.add(
                Token(type: TokenTypes.bangEqual, lexeme: '!=', line: line));
            advance();
          } else {
            tokens.add(Token(type: TokenTypes.bang, lexeme: '!', line: line));
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
        type: TokenTypes.string, lexeme: '"$value"', value: value, line: line);
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
        type: TokenTypes.number, lexeme: value, value: value, line: line);
  }

  Token identifier() {
    String value = '';

    do {
      value += peek();
      advance();
    } while (peek().isNotEmpty && isAlphaNumeric());

    TokenTypes? type = getKeyword(value);
    type ??= TokenTypes.identifier;

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

  TokenTypes? getKeyword(String value) {
    Iterable<TokenTypes> results = TokenTypes.values
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
