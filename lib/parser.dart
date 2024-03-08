import 'package:lox_dart/lox_dart.dart';

class Parser {
  final List<Token> input;
  final List<ParseError> errors = [];

  int _pos = 0;

  Parser(this.input);

  Expr parse() {
    return expression();
  }

  Expr expression() {
    return equality();
  }

  Expr equality() {
    Expr expr = comparison();

    while (match([TokenType.bangEqual, TokenType.equalEqual])) {
      Token operator = peek();
      advance();
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
      Token operator = peek();
      advance();
      Expr right = term();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr term() {
    Expr expr = factor();

    while (match([TokenType.minus, TokenType.plus])) {
      Token operator = peek();
      advance();
      Expr right = factor();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr factor() {
    Expr expr = unary();

    while (match([TokenType.division, TokenType.product])) {
      Token operator = peek();
      advance();
      Expr right = unary();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr unary() {
    if (match([TokenType.bang, TokenType.minus])) {
      Token operator = peek();
      advance();
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
      confirm(TokenType.parenRight, 'Closing ")" expected.');

      return expr;
    } else {
      Expr expr = Literal(peek().value);
      advance();
      return expr;
    }
  }

  void confirm(TokenType type, String msg) {
    if (peek().type != type) {
      errors.add(ParseError(msg));
    }
  }

  void advance() {
    _pos++;
  }

  bool match(List<TokenType> types) {
    return types.contains(input[_pos].type);
  }

  Token peek() {
    return input[_pos];
  }
}

class ParseError extends Error {
  final String description;

  ParseError(this.description);
}
