import 'package:luxx_dart/lox_dart.dart';
import 'package:luxx_dart/luxx_ffi_dart.dart';
import 'package:luxx_dart/luxx_dfi.dart';
import 'package:luxx_dart/native_funs.dart';

import 'luxx_array.dart';
import 'luxx_map.dart';
import 'monitor.dart';

final Environment globals = Environment();
Interpreter gInterpreter = Interpreter(); // gets replaced as soon as someone does some real work

void receiveDartEvents() {
  gInterpreter.handleCallFromDart();
}

class Interpreter with ExprVisitor<Object?>, StmtVisitor<void> {
  List<InterpretError> errors = [];
  late Environment environment;
  final Map<Expr, int> locals = {};
  bool _debugLocals = false; // that is for a print in "locals()"

  Interpreter() {
    environment = globals;

    gInterpreter = this;

    // initialize the dart <-> luxx bridge
    luxx = receiveDartEvents;
    globals.define('sent2dart', Darcy()); // TODO AoS find a better name
    globals.define('dart', ThrowTheDart());

    // just an example, but kind of useful
    globals.define('clock', Clock());

    // the following are objects of classes that implement the LoxCallable interface
    globals.define('arrayCreate', ArrayCreate());
    globals.define('arrayLength', ArrayLength());
    globals.define('arrayAdd', ArrayAdd());
    globals.define('arraySetAt', ArraySet());
    globals.define('arrayGetAt', ArrayGet());

    globals.define('mapCreate', MapCreate());
    globals.define('mapLength', MapLength());
    globals.define('mapSetAt', MapSet());
    globals.define('mapGetAt', MapGet());
  }

  // as some code assumes the globals are the last resort
  // we put our injected "globals" behind the actual globals.
  Environment injectXEnv(Environment env) {
    globals.enclosing = env;
    return env;
  }

  static void listIntrinsics() {
    print(globals.vars);
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
  void visitContractStmt(Contract cont) {
    // do nothing, this is in the function call ... AoS todo: figure if we even need this method
  }

  @override
  void visitBreakStmt(Break break$) {
    Object? result = evaluate(break$.expression);
    print(stringify(result));

    // PoI: breaking into the monitor.
    // set a breakpoint inside of the monitor package to
    // investigate stuff of interest with the debugger
    // You do not really need a Breakpoint as you end in
    // the Repl-Monitor now.
    Monitor m = Monitor();
    m.runRepl(fromInterpreter: true);
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
    //_debugLocals = true;
    final left = evaluate(expr.left);
    //_debugLocals = false;
    final right = evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.plus:
        if (left is double && right is double) {
          return left + right;
        }
        if (left is String) { // works now with LuxInstance's
          return left + right.toString();
        }
        return left.toString() + " + " + right.toString();

        // AoS todo left side can be a LoxInstance
        // AoS we already have to think about FFI here:
        //     how to call a toString() method that is defined in lox/luxx
        throw InterpretError(
            'Both values must be strings or numbers (AoS: OOPS, how did we get here?)',
            expr.operator.line);

      case TokenType.minus:
        _checkNumberOperands(expr.operator, [left, right]);
        return (left as double) - (right as double);

      case TokenType.star: // "is LoxInstance?"
        _checkNumberOperands(expr.operator, [left, right]);
        return (left as double) * (right as double);

      case TokenType.slash:
        _checkNumberOperands(expr.operator, [left, right]);
        return (left as double) / (right as double);

    // PoI
      case TokenType.modulo:
        // debugPrintObjects([expr.operator, left, right]);
        if (left is String && right is LoxInstance) {
          LoxInstance li = right as LoxInstance;
          var theMap = li.getInstanceAsMap();
          String s = expandMapIntoString(
              left as String, theMap.cast<String, Object>());
          return s;
        }
        _checkNumberOperands(expr.operator, [left, right]);
        return (left as double) % (right as double);

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
    final function = evaluate(expr.callee); // HERE AoS

    List<Object?> arguments = [];
    for (final argument in expr.arguments) {
      arguments.add(evaluate(argument));
    }

    // AoS for variable length argument calls we probably only have to fix here
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
    if (_debugLocals) {
      print("Key: ${expr}");
      for (var l in locals.keys) {
        // HERE AoS
        print("Loc: " + l.toString());
      }
    }
    if (locals[expr] != null) {
      if (_debugLocals) print ("Key: ${expr} :-> ${locals[expr]!}\n");
      return environment.getAt(locals[expr]!, name.lexeme);
    } else {
      return globals.get(name);
    }
  }

  bool executeRequireConstraints(Contract contract, Environment environment) {
    if (contract.hasRequirements()) { // AoS push one call layer up
      Environment previous = this.environment;
      try {
        this.environment = environment;
        var req = contract.require!;
        bool res = true;
        for (var it in req) {
          var midres = evaluate(it);
          res = res && midres as bool;
          print ("$it :-> $midres");
        }
        // AoS TODO, fiffle the line out and print it here
        if (!res) print ("Error in Interpreter (IGNORED) :-> 'require' constraint failed!");
        return res; // HERE return the faulty statement/expression?
      } finally {
        this.environment = previous;
      }
    } else {
      return true;
    }
  }
  bool executeEnsureConstraints(Contract contract, Environment environment) {
    if (contract.doesEnsure()) { // AoS push one call layer up
      Environment previous = this.environment;
      try {
        this.environment = environment;
        var req = contract.ensure!;
        bool res = true;
        for (var it in req) {
          var midres = evaluate(it);
          res = res && midres as bool;
          // print ("$it :-> $midres");
        }
        // AoS TODO, fiffle the line out and print it here
        if (!res) print ("Error in Interpreter (IGNORED) :-> 'ensure' constraint failed!");
        return res; // HERE return the faulty statement/expression?
      } finally {
        this.environment = previous;
      }
    } else {
      return true;
    }
  }
  bool executeInvariantConstraints(Contract contract, Environment environment) {
    if (contract.hasInvariant()) { // AoS push one call layer up
      Environment previous = this.environment;
      try {
        this.environment = environment;
        var req = contract.invariant!;
        bool res = true;
        for (var it in req) {
          var midres = evaluate(it);
          res = res && midres as bool;
          print ("$it :-> $midres");
        }
        // AoS TODO, fiffle the line out and print it here
        if (!res) print ("Error in Interpreter (IGNORED) :-> invariant constraint failed!");
        return res; // HERE return the faulty statement/expression?
      } finally {
        this.environment = previous;
      }
    } else {
      return true;
    }
  }

  void handleCallFromDart() {
    while (gLuxxy.isNotEmpty) {
      var it = gLuxxy.removeAt(0);
      // todo aos handle the call
      print (it);
    }
  }

}

class InterpretError extends Error {
  final String description;
  final int line;

  InterpretError(this.description, this.line) {
  }
}
