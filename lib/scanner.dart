import 'package:lox_dart/token.dart';

class Scanner {
  final String input;
  final List<Token> tokens = [];
  final List<ScanError> errors = [];

  int _pos = 0;
  int line = 1;

  Scanner(this.input);

  List<Token> scan() {
    while (peek().isNotEmpty) {
      switch (peek()) {
        case ' ':
        case '\t':
          advance();
          break;

        case '\n':
          line++;
          advance();
          break;

        case '+':
          addToken(TokenType.plus, '+');
          advance();
          break;

        case '-':
          addToken(TokenType.minus, '-');
          advance();
          break;

        case '*':
          addToken(TokenType.product, '*');
          advance();
          break;

        case '{':
          addToken(TokenType.braceLeft, '{');
          advance();
          break;

        case '}':
          addToken(TokenType.braceRight, '}');
          advance();
          break;

        case '(':
          addToken(TokenType.parenLeft, '(');
          advance();
          break;

        case ')':
          addToken(TokenType.parenRight, ')');
          advance();
          break;

        case ';':
          addToken(TokenType.semicolon, ';');
          advance();
          break;

        case '/':
          advance();
          if (peek() == '/') {
            comment();
          } else {
            addToken(TokenType.division, '/');
          }
          break;

        case '<':
          advance();
          if (peek() == '=') {
            advance();
            addToken(TokenType.lessEqual, '<=');
          } else {
            addToken(TokenType.less, '<');
          }
          break;

        case '>':
          advance();
          if (peek() == '=') {
            addToken(TokenType.greaterEqual, '>=');
            advance();
          } else {
            addToken(TokenType.greater, '>');
          }
          break;

        case '=':
          advance();
          if (peek() == '=') {
            addToken(TokenType.equalEqual, '==');
            advance();
          } else {
            addToken(TokenType.equal, '=');
          }
          break;

        case '!':
          advance();
          if (peek() == '=') {
            addToken(TokenType.bangEqual, '!=');
            advance();
          } else {
            addToken(TokenType.bang, '!');
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
          } else {
            errors.add(ScanError('Unexpected character.'));
            advance();
          }
      }
    }

    addToken(TokenType.eof, '');
    return tokens;
  }

  void addToken(TokenType type, String lexeme) {
    tokens.add(Token(type: type, lexeme: lexeme, line: line));
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
