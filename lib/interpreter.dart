import 'package:lox_dart/lox_dart.dart';

class Interpreter with ExprVisitor<Object?>, StmtVisitor<void> {
  List<InterpretError> errors = [];
  Environment environment = Environment();

  void interpret(List<Stmt> statements) {
    for (final stmt in statements) {
      try {
        execute(stmt);
      } catch (e) {
        if (e is! InterpretError) {
          errors.add(InterpretError(e.toString(), 1));
        } else {
          errors.add(e);
        }
      }
    }
  }

  void execute(Stmt stmt) {
    stmt.accept(this);
  }

  Object? evaluate(Expr expr) {
    return expr.accept(this);
  }

  @override
  void visitPrintStmt(Print stmt) {
    Object? result = evaluate(stmt.expression);
    print(stringify(result));
  }

  @override
  void visitBlockStmt(Block stmt) {
    executeBlock(stmt.statements, Environment(environment));
  }

  void executeBlock(List<Stmt> statements, Environment environment) {
    Environment previous = this.environment;
    try {
      this.environment = environment;
      for (final stmt in statements) {
        execute(stmt);
      }
    } finally {
      this.environment = previous;
    }
  }

  @override
  void visitVarStmt(Var stmt) {
    Object? value;

    if (stmt.initializer != null) {
      value = evaluate(stmt.initializer!);
    }

    environment.define(stmt.name.lexeme, value);
  }

  @override
  void visitExpressionStmt(Expression stmt) {
    evaluate(stmt.expression);
  }

  @override
  Object? visitAssignExpr(Assign expr) {
    Object? value = evaluate(expr.value);
    environment.assign(expr.name, value);
    return value;
  }

  @override
  Object? visitBinaryExpr(Binary expr) {
    final left = evaluate(expr.left);
    final right = evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.plus:
        if (left is double && right is double) {
          return left + right;
        }
        if (left is String && right is String) {
          return left + right;
        }
        throw InterpretError(
            'Both values must be strings or numbers', expr.operator.line);

      case TokenType.minus:
        _checkNumberOperands(expr.operator, [left, right]);
        return (left as double) - (right as double);

      case TokenType.star:
        _checkNumberOperands(expr.operator, [left, right]);
        return (left as double) * (right as double);

      case TokenType.slash:
        _checkNumberOperands(expr.operator, [left, right]);
        return (left as double) / (right as double);

      case TokenType.greater:
        _checkNumberOperands(expr.operator, [left, right]);
        return (left as double) > (right as double);

      case TokenType.greaterEqual:
        _checkNumberOperands(expr.operator, [left, right]);
        return (left as double) >= (right as double);

      case TokenType.less:
        _checkNumberOperands(expr.operator, [left, right]);
        return (left as double) < (right as double);

      case TokenType.lessEqual:
        _checkNumberOperands(expr.operator, [left, right]);
        return (left as double) <= (right as double);

      case TokenType.equalEqual:
        return left == right;

      case TokenType.bangEqual:
        return left != right;

      default:
        throw InterpretError('Unrecognized expression', expr.operator.line);
    }
  }

  @override
  Object? visitGroupingExpr(Grouping expr) {
    return evaluate(expr.expression);
  }

  @override
  Object? visitUnaryExpr(Unary expr) {
    final right = evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.bang:
        return !_isTruthy(right);

      case TokenType.minus:
        if (right is double) {
          return -right;
        }
        throw InterpretError('Value must be number', expr.operator.line);

      default:
        throw InterpretError('Unrecognized expression', expr.operator.line);
    }
  }

  @override
  Object? visitVariableExpr(Variable expr) {
    return environment.get(expr.name);
  }

  @override
  Object? visitLiteralExpr(Literal expr) {
    return expr.value;
  }

  bool _isTruthy(Object? object) {
    if (object == null) return false;
    if (object is bool) return object;
    return true;
  }

  void _checkNumberOperands(Token token, List<Object?> operands) {
    final allNumbers = operands.fold(
        true, (previousValue, element) => previousValue && (element is double));

    if (!allNumbers) {
      throw InterpretError('Operands must be numbers', token.line);
    }
  }

  String stringify(Object? object) {
    if (object == null) return 'nil';

    if (object is double) {
      var text = object.toString();
      if (text.endsWith('.0')) {
        text = text.substring(0, text.length - 2);
      }
      return text;
    }

    return object.toString();
  }
}

class InterpretError extends Error {
  final String description;
  final int line;

  InterpretError(this.description, this.line);
}
