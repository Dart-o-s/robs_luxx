import 'package:lox_dart/token.dart';

class Scanner {
  final String input;
  final List<Token> tokens = [];
  final List<ScanError> errors = [];

  int _pos = 0;
  int line = 1;

  final Map<String, TokenType> _keywords = {
    'and': TokenType.and,
    'class': TokenType.class$,
    'else': TokenType.else$,
    'false': TokenType.false$,
    'for': TokenType.for$,
    'fun': TokenType.fun,
    'if': TokenType.if$,
    'nil': TokenType.nil,
    'or': TokenType.or,
    'print': TokenType.print,
    'return': TokenType.return$,
    'super': TokenType.super$,
    'this': TokenType.this$,
    'true': TokenType.true$,
    'var': TokenType.var$,
    'while': TokenType.while$,
  };

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

        case '.':
          addToken(TokenType.dot, '.');
          advance();
          break;

        case ',':
          addToken(TokenType.comma, ',');
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
          addToken(TokenType.star, '*');
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
            addToken(TokenType.slash, '/');
          }
          break;

        case '<':
          advance();
          if (peek() == '=') {
            addToken(TokenType.lessEqual, '<=');
            advance();
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
          string();
          break;

        default:
          if (isNumeric()) {
            number();
          } else if (isAlphaNumeric()) {
            identifier();
          } else {
            errors.add(ScanError('Unexpected character "${peek()}" found', line));
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

  void string() {
    advance();

    String value = '';
    while (peek().isNotEmpty && peek() != '"') {
      value += peek();
      advance();
    }

    if (peek().isEmpty) {
      errors.add(ScanError('Closing \'"\' expected', line));
    } else {
      advance();
    }

    tokens.add(Token(
        type: TokenType.string, lexeme: '"$value"', value: value, line: line));
  }

  void number() {
    String value = '';
    bool hasDecimal = false;

    do {
      value += peek();
      advance();

      if (!isNumeric()) {
        if (peek() == '.' && !hasDecimal) {
          hasDecimal = true;
        } else {
          break;
        }
      }
    } while (peek().isNotEmpty);

    tokens.add(Token(
        type: TokenType.number,
        lexeme: value,
        value: double.parse(value),
        line: line));
  }

  void identifier() {
    String value = '';

    do {
      value += peek();
      advance();
    } while (peek().isNotEmpty && isAlphaNumeric());

    TokenType? type = _keywords[value];
    type ??= TokenType.identifier;

    tokens.add(Token(type: type, lexeme: value, line: line));
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
}

class ScanError extends Error {
  final String description;
  final int line;

  ScanError(this.description, this.line);
}
