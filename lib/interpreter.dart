import 'package:lox_dart/lox_dart.dart';
import 'package:lox_dart/native_funs.dart';

class Interpreter with ExprVisitor<Object?>, StmtVisitor<void> {
  List<InterpretError> errors = [];
  final Environment globals = Environment();
  late Environment environment;
  final Map<Expr, int> locals = {};

  Interpreter() {
    environment = globals;
    globals.define('clock', Clock());
  }

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
  void visitReturnStmt(Return stmt) {
    Object? value;
    if (stmt.value != null) {
      value = evaluate(stmt.value!);
    }

    throw ReturnException(value);
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
  void visitWhileStmt(While stmt) {
    while (_isTruthy(evaluate(stmt.condition))) {
      execute(stmt.body);
    }
  }

  @override
  void visitExpressionStmt(Expression stmt) {
    evaluate(stmt.expression);
  }

  @override
  void visitClassStmt(Class stmt) {
    Object? superclass;
    if (stmt.superclass != null) {
      superclass = evaluate(stmt.superclass!);
      if (superclass is! LoxClass) {
        throw InterpretError('Superclass must be a class.', stmt.name.line);
      }
    }

    environment.define(stmt.name.lexeme, null);

    if (stmt.superclass != null) {
      environment = Environment(environment);
      environment.define('super', superclass);
    }

    Map<String, LoxFunction> methods = {};
    for (Fun method in stmt.methods) {
      LoxFunction function =
          LoxFunction(method, environment, method.name.lexeme == 'init');
      methods[method.name.lexeme] = function;
    }

    LoxClass klass = LoxClass(stmt.name.lexeme,
        (superclass != null ? superclass as LoxClass : null), methods);

    if (stmt.superclass != null) {
      environment = environment.enclosing!;
    }

    environment.assign(stmt.name, klass);
  }

  @override
  void visitFunStmt(Fun stmt) {
    environment.define(stmt.name.lexeme, LoxFunction(stmt, environment, false));
  }

  @override
  void visitIfStmt(If stmt) {
    if (_isTruthy(evaluate(stmt.condition))) {
      execute(stmt.thenBranch);
    } else if (stmt.elseBranch != null) {
      execute(stmt.elseBranch!);
    }
  }

  @override
  Object? visitAssignExpr(Assign expr) {
    Object? value = evaluate(expr.value);
    if (locals[expr] != null) {
      environment.assignAt(locals[expr]!, expr.name, value);
    } else {
      environment.assign(expr.name, value);
    }

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
        if (left is String) {
          return left + right.toString();
        }
        throw InterpretError(
            'Both values must be strings or numbers (AoS: OOPS, how did we get here?)', expr.operator.line);

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
  Object? visitCallExpr(Call expr) {
    final function = evaluate(expr.callee);

    List<Object?> arguments = [];
    for (final argument in expr.arguments) {
      arguments.add(evaluate(argument));
    }

    if (function is! LoxCallable) {
      throw InterpretError(
          'Can only call functions and classes', expr.paren.line);
    }

    if (arguments.length != function.arity()) {
      throw InterpretError(
          'Expected ${function.arity()} arguments but got ${arguments.length}',
          expr.paren.line);
    }

    return function.call(this, arguments);
  }

  @override
  Object? visitGetExpr(Get expr) {
    final instance = evaluate(expr.object);

    if (instance is! LoxInstance) {
      throw InterpretError(
          'Can only call properties on instances', expr.name.line);
    }

    return instance.get(expr.name);
  }

  @override
  Object? visitSetExpr(Set expr) {
    final instance = evaluate(expr.object);

    if (instance is! LoxInstance) {
      throw InterpretError(
          'Can only call properties on instances', expr.name.line);
    }

    Object? value = evaluate(expr.value);
    instance.set(expr.name.lexeme, value);
    return value;
  }

  @override
  Object? visitSuperExpr(Super expr) {
    int distance = locals[expr]!;
    Object? superclass = environment.getAt(distance, 'super');
    Object? object = environment.getAt(distance - 1, 'this');
    Object? method = (superclass as LoxClass).findMethod(expr.name.lexeme);

    if (method != null && method is LoxFunction) {
      return method.bind(object as LoxInstance);
    }

    throw InterpretError(
        'Undefined property "${expr.name.lexeme}"', expr.name.line);
  }

  @override
  Object? visitThisExpr(This expr) {
    return lookUpVariable(expr.keyword, expr);
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
    return lookUpVariable(expr.name, expr);
  }

  @override
  Object? visitLiteralExpr(Literal expr) {
    return expr.value;
  }

  @override
  Object? visitLogicalExpr(Logical expr) {
    Object? left = evaluate(expr.left);

    if (expr.operator.type == TokenType.or && _isTruthy(left)) {
      return left;
    }

    if (expr.operator.type == TokenType.and && !_isTruthy(left)) {
      return left;
    }

    return evaluate(expr.right);
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

  void resolve(Expr expr, int depth) {
    locals[expr] = depth;
  }

  Object? lookUpVariable(Token name, Expr expr) {
    if (locals[expr] != null) {
      return environment.getAt(locals[expr]!, name.lexeme);
    } else {
      return globals.get(name);
    }
  }
}

class InterpretError extends Error {
  final String description;
  final int line;

  InterpretError(this.description, this.line);
}
