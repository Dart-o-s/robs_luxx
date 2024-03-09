import 'package:lox_dart/lox_dart.dart';

class Parser {
  final List<Token> tokens;
  final List<ParseError> errors = [];

  int _pos = 0;

  Parser(this.tokens);

  Expr? parse() {
    Expr? expr;

    try {
      expr = expression();
    } catch (e) {
      errors.add(e as ParseError);
      return null;
    }

    return expr;
  }

  Expr expression() {
    return equality();
  }

  Expr equality() {
    Expr expr = comparison();

    while (match([TokenType.bangEqual, TokenType.equalEqual])) {
      Token operator = peekAndAdvance();
      Expr right = comparison();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr comparison() {
    Expr expr = term();

    while (match([
      TokenType.greater,
      TokenType.greaterEqual,
      TokenType.less,
      TokenType.lessEqual
    ])) {
      Token operator = peekAndAdvance();
      Expr right = term();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr term() {
    Expr expr = factor();

    while (match([TokenType.minus, TokenType.plus])) {
      Token operator = peekAndAdvance();
      Expr right = factor();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr factor() {
    Expr expr = unary();

    while (match([TokenType.division, TokenType.product])) {
      Token operator = peekAndAdvance();
      Expr right = unary();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr unary() {
    if (match([TokenType.bang, TokenType.minus])) {
      Token operator = peekAndAdvance();
      Expr operand = unary();
      return Unary(operator, operand);
    } else {
      return primary();
    }
  }

  Expr primary() {
    if (match([TokenType.parenLeft])) {
      advance();
      Expr expr = expression();
      confirmAndAdvance(TokenType.parenRight, 'Closing ")" expected.');
      return Grouping(expr);
    } else {
      switch (peek().type) {
        case TokenType.number:
        case TokenType.string:
          return Literal(peekAndAdvance().value);
        case TokenType.true$:
          advance();
          return Literal(true);
        case TokenType.false$:
          advance();
          return Literal(false);
        case TokenType.nil:
          advance();
          return Literal(null);

        default:
          final msg = 'Token ${peek().type} cannot be parse, yet.';
          throw ParseError(msg, peek().line);
      }
    }
  }

  void confirmAndAdvance(TokenType type, String msg) {
    if (peek().type != type) {
      throw ParseError(msg, peek().line);
    } else {
      advance();
    }
  }

  void advance() {
    _pos++;
  }

  bool match(List<TokenType> types) {
    return types.contains(tokens[_pos].type);
  }

  Token peek() {
    return tokens[_pos];
  }

  Token peekAndAdvance() {
    Token token = peek();
    advance();
    return token;
  }

  void synchronize() {
    advance();

    while (!match([TokenType.eof])) {
      if (match([
        TokenType.semicolon,
        TokenType.fun,
        TokenType.var$,
        TokenType.for$,
        TokenType.if$,
        TokenType.while$,
        TokenType.print,
        TokenType.return$
      ])) return;
      advance();
    }
  }
}

class ParseError extends Error {
  final String description;
  final int line;

  ParseError(this.description, this.line);
}
