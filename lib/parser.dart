import 'package:lox_dart/lox_dart.dart';

class Parser {
  final List<Token> tokens;
  final List<ParseError> errors = [];

  int _pos = 0;

  Parser(this.tokens);

  List<Stmt> parse() {
    List<Stmt> stmts = [];

    while (!match([TokenType.eof])) {
      try {
        stmts.add(declaration());
      } catch (e) {
        errors.add(e as ParseError);
        synchronize();
      }
    }

    return stmts;
  }

  Stmt declaration() {
    if (match([TokenType.var$])) {
      return varDeclaration();
    } else {
      return statement();
    }
  }

  Stmt varDeclaration() {
    advance();
    ensure(TokenType.identifier, 'Expect variable name.');
    Token name = peekAndAdvance();
    Expr? initializer;

    if (match([TokenType.equal])) {
      advance();
      initializer = expression();
    }

    ensureAndAdvance(TokenType.semicolon, 'Expect ";" after declaration.');
    return Var(name, initializer);
  }

  Stmt statement() {
    if (match([TokenType.print])) {
      return printStmt();
    } else {
      return expressionStmt();
    }
  }

  Stmt printStmt() {
    advance();
    Expr expr = expression();
    ensureAndAdvance(TokenType.semicolon, 'Expect ";" after value.');
    return Print(expr);
  }

  Stmt expressionStmt() {
    Expr expr = expression();
    ensureAndAdvance(TokenType.semicolon, 'Expect ";" after expression.');
    return Expression(expr);
  }

  Expr expression() {
    return assignment();
  }

  Expr assignment() {
    Expr expr = equality();

    if (match([TokenType.equal])) {
      Token equals = peek();
      advance();

      if (expr is Variable) {
        Expr value = assignment();
        return Assign(expr.name, value);
      }

      throw ParseError('Invalid assignment target', equals.line);
    }

    return expr;
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

    while (match([TokenType.slash, TokenType.star])) {
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
      ensureAndAdvance(TokenType.parenRight, 'Closing ")" expected.');
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
        case TokenType.identifier:
          return Variable(peekAndAdvance());

        default:
          final msg = 'Token ${peek().type} cannot be parse, yet.';
          throw ParseError(msg, peek().line);
      }
    }
  }

  void ensure(TokenType type, String msg) {
    if (peek().type != type) {
      throw ParseError(msg, peek().line);
    }
  }

  void ensureAndAdvance(TokenType type, String msg) {
    ensure(type, msg);
    advance();
  }

  void advance([int steps = 1]) {
    _pos += steps;
  }

  bool match(List<TokenType> types, [int offset = 0]) {
    return types.contains(tokens[_pos + offset].type);
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
