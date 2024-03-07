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

        case '<':
          advance();
          if (peek() == '=') {
            advance();
            tokens.add(Token(type: TokenTypes.lessEqual, lexeme: '<='));
          } else {
            tokens.add(Token(type: TokenTypes.less, lexeme: '<'));
          }
          break;

        case '>':
          advance();
          if (peek() == '=') {
            tokens.add(Token(type: TokenTypes.greaterEqual, lexeme: '>='));
            advance();
          } else {
            tokens.add(Token(type: TokenTypes.greater, lexeme: '>'));
          }
          break;

        case '=':
          advance();
          if (peek() == '=') {
            tokens.add(Token(type: TokenTypes.equalEqual, lexeme: '=='));
            advance();
          } else {
            tokens.add(Token(type: TokenTypes.equal, lexeme: '='));
          }
          break;

        case '!':
          advance();
          if (peek() == '=') {
            tokens.add(Token(type: TokenTypes.bangEqual, lexeme: '!='));
            advance();
          } else {
            tokens.add(Token(type: TokenTypes.bang, lexeme: '!'));
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
    } while (!isOutOfRange() && peek() != '\n');
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

    return Token(type: TokenTypes.string, lexeme: '"$value"', value: value);
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

    return Token(type: TokenTypes.number, lexeme: value, value: value);
  }

  Token identifier() {
    String value = '';

    do {
      value += peek();
      advance();
    } while (peek().isNotEmpty && isAlphaNumeric());

    TokenTypes? type = getKeyword(value);
    type ??= TokenTypes.identifier;

    return Token(type: type, lexeme: value, value: value);
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
