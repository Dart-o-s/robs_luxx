import 'package:lox_dart/lox_dart.dart';

import 'machine.dart';

class Parser {
  int _pos = 0;
  final List<Token> tokens;
  final List<ParseError> errors = [];
  final List<Stmt> stmts = [];

  Parser(this.tokens) {
    Machine.gMachine.setTokens(tokens);
    Machine.gMachine.setStatements(stmts);
  }

  List<Stmt> parse() {

    while (!match([TokenType.eof])) {
      try {
        stmts.add(declaration());
      } catch (e) {
        if (e is! ParseError) {
          errors.add(ParseError(e.toString(), 1));
        } else {
          errors.add(e);
        }
        synchronize();
      }
    }

    // PoI end of parsing
    print ("Amount of Statements parsed: ${stmts.length} statements.");
    return stmts;
  }

  Stmt declaration() {
    if (match([TokenType.class$])) {
      advance();
      return classDeclaration();
    } else if (match([TokenType.fun])) {
      advance();
      return funDeclaration('function');
    } else if (match([TokenType.var$])) {
      return varDeclaration();
    } else {
      return statement();
    }
  }

  Stmt classDeclaration() {
    ensure(TokenType.identifier, 'Expect class name.');
    Token name = peekAndAdvance();
    Variable? superclass;

    if (match([TokenType.less])) {
      advance();
      ensure(TokenType.identifier, 'Expect superclass name.');
      superclass = Variable(peekAndAdvance());
    }

    ensureAndAdvance(TokenType.braceLeft, 'Expect "{" after class name.');
    List<Fun> methods = [];

    while (!match([TokenType.braceRight, TokenType.eof])) {
      methods.add(funDeclaration('method') as Fun);
    }

    ensureAndAdvance(TokenType.braceRight, 'Expect "}" after class body.');
    return Class(name, superclass, methods);
  }

  Stmt funDeclaration(String kind) {
    // Aos probably we get away by inventing an "anon-#x name" - if kind is function
    ensure(TokenType.identifier, 'Expect $kind name.');
    Token name = peekAndAdvance();
    ensureAndAdvance(TokenType.parenLeft, 'Expect "(" after $kind name.');
    List<Token> params = [];

    if (!match([TokenType.parenRight])) {
      do {
        if (params.length >= 255) {
          errors.add(
              ParseError('Cannot have more than 255 parameters.', peek().line));
        }

        ensure(TokenType.identifier, 'Expect parameter name.');
        params.add(peekAndAdvance());
      } while (matchAndAdvance([TokenType.comma]));
    }

    ensureAndAdvance(TokenType.parenRight, 'Expect ")" after parameters.');
    ensureAndAdvance(TokenType.braceLeft, 'Expect "{" before $kind body.');
    return Fun(name, params, block());
  }

  Stmt varDeclaration() {
    advance();
    ensure(TokenType.identifier, 'Expect variable name.');
    Token name = peekAndAdvance();
    Expr? initializer;

    if (matchAndAdvance([TokenType.equal])) {
      initializer = expression();
    }

    ensureAndAdvance(TokenType.semicolon, 'Expect ";" after declaration.');
    return Var(name, initializer);
  }

  Stmt statement() {
    if (match([TokenType.if$])) {
      return ifStmt();
    } else if (match([TokenType.print])) {
      return printStmt();
    } else if (match([TokenType.BRK])) {
      return brkStmt();
    } else if (match([TokenType.return$])) {
      return returnStmt();
    } else if (match([TokenType.for$])) {
      return forStmt();
    } else if (match([TokenType.while$])) {
      return whileStmt();
    } else if (match([TokenType.braceLeft])) {
      advance();
      return Block(block());
    } else {
      return expressionStmt();
    }
  }

  Stmt ifStmt() {
    advance();
    ensureAndAdvance(TokenType.parenLeft, 'Expect "(" after if.');

    Expr condition = expression();
    ensureAndAdvance(TokenType.parenRight, 'Expect ")" after expression.');

    Stmt thenBranch = statement();
    Stmt? elseBranch;

    if (matchAndAdvance([TokenType.else$])) {
      elseBranch = statement();
    }

    return If(condition, thenBranch, elseBranch);
  }

  Stmt printStmt() {
    advance();
    Expr expr = expression();
    ensureAndAdvance(TokenType.semicolon, 'Expect ";" after value.');
    return Print(expr);
  }

  Stmt brkStmt() {
    advance();
    Expr expr = expression();
    ensureAndAdvance(TokenType.semicolon, 'Expect ";" after value.');
    return Break(expr);
  }

  Stmt returnStmt() {
    Token keyword = peekAndAdvance();
    Expr? expr;

    if (!match([TokenType.semicolon])) {
      expr = expression();
    }

    ensureAndAdvance(
        TokenType.semicolon, 'Expect ";" after keyword or expression.');
    return Return(keyword, expr);
  }

  Stmt forStmt() {
    advance();
    ensureAndAdvance(TokenType.parenLeft, 'Expect "(" after for.');

    Stmt? initializer;
    if (match([TokenType.var$])) {
      initializer = varDeclaration();
    } else if (!match([TokenType.semicolon])) {
      initializer = expressionStmt();
    } else {
      ensureAndAdvance(TokenType.semicolon, 'Expect ";" after initializer.');
    }

    Expr? condition;
    if (!match([TokenType.semicolon])) {
      condition = expression();
    }
    ensureAndAdvance(TokenType.semicolon, 'Expect ";" after condition.');

    Expr? increment;
    if (!match([TokenType.parenRight])) {
      increment = expression();
    }

    ensureAndAdvance(TokenType.parenRight, 'Expect ")" after increment.');
    Stmt body = statement();

    if (increment != null) {
      body = Block([body, Expression(increment)]);
    }

    if (condition != null) {
      body = While(condition, body);
    } else {
      body = While(Literal(true), body);
    }

    if (initializer != null) {
      body = Block([initializer, body]);
    }

    return body;
  }

  Stmt whileStmt() {
    advance();
    ensureAndAdvance(TokenType.parenLeft, 'Expect "(" after while.');

    Expr condition = expression();
    ensureAndAdvance(TokenType.parenRight, 'Expect ")" after condition.');

    Stmt body = statement();
    return While(condition, body);
  }

  List<Stmt> block() {
    List<Stmt> statements = [];

    while (!match([TokenType.braceRight, TokenType.eof])) {
      statements.add(declaration());
    }

    ensureAndAdvance(TokenType.braceRight, 'Expect "}" after block.');
    return statements;
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
    Expr expr = logicOr();

    if (match([TokenType.equal])) {
      Token equals = peekAndAdvance();
      Expr value = assignment();

      if (expr is Variable) {
        return Assign(expr.name, value);
      } else if (expr is Get) {
        Get get = expr;
        return Set(get.object, get.name, value);
      }

      throw ParseError('Invalid assignment target', equals.line);
    }

    return expr;
  }

  Expr logicOr() {
    Expr expr = logicAnd();

    if (match([TokenType.or])) {
      Token operator = peekAndAdvance();
      Expr right = logicAnd();
      expr = Logical(expr, operator, right);
    }

    return expr;
  }

  Expr logicAnd() {
    Expr expr = equality();

    if (match([TokenType.and])) {
      Token operator = peekAndAdvance();
      Expr right = equality();
      expr = Logical(expr, operator, right);
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

    //  TokenType.modulo
    while (match([TokenType.slash, TokenType.star, TokenType.modulo])) {
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
      return call();
    }
  }

  Expr call() {
    Expr callee = primary();

    while (true) {
      if (match([TokenType.parenLeft])) {
        callee = finishCall(callee);
      } else if (match([TokenType.dot])) {
        advance();
        ensure(TokenType.identifier, 'Expect property name after dot.');
        Token name = peekAndAdvance();
        callee = Get(callee, name);
      } else {
        break;
      }
    }

    return callee;
  }

  Expr finishCall(callee) {
    Token paren = peekAndAdvance();
    List<Expr> arguments = [];

    if (!match([TokenType.parenRight])) {
      do {
        if (arguments.length >= 255) {
          errors.add(
              ParseError('Cannot have more than 255 arguments.', peek().line));
        }

        arguments.add(expression());
      } while (matchAndAdvance([TokenType.comma]));
    }

    ensureAndAdvance(TokenType.parenRight, 'Expect ")" after arguments.');
    return Call(callee, paren, arguments);
  }

  Expr primary() {
    if (matchAndAdvance([TokenType.parenLeft])) {
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
        case TokenType.this$:
          return This(peekAndAdvance());
        case TokenType.super$:
          Token kw = peekAndAdvance();
          ensureAndAdvance(TokenType.dot, 'Expect "." after super keyword.');
          ensure(TokenType.identifier, 'Expect method name for "super".');
          return Super(kw, peekAndAdvance());

        default:
          final msg = 'Token ${peek().type} cannot be parse, yet.';
          print(msg);
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

  bool matchAndAdvance(List<TokenType> types) {
    final result = match(types);
    if (result) {
      advance();
    }
    return result;
  }

  Token peek() {
    var tk = tokens[_pos];
    if (tk.type == TokenType.printAst) {
      print(tk.eolComment);
      printAst();
      _pos++;
    }

    return tokens[_pos];
  }

  Token peekAndAdvance() {
    Token token = peek();
    advance();
    return token;
  }

  void synchronize() {
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

  void printAst() {
    print("OOPS: the AstPrinter can only walk expressions");
  }
}

class ParseError extends Error {
  final String description;
  final int line;

  ParseError(this.description, this.line);
}
