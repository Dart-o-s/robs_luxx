import 'package:luxx_dart/lox_dart.dart';

enum FunctionType { none, function, initializer, method }

enum ClassType { none, klass, subklass }

class Resolver with ExprVisitor<void>, StmtVisitor<void> {
  List<ResolveError> errors = [];
  final List<Map<String, bool>> scopes = [];
  FunctionType currentFunction = FunctionType.none;
  ClassType currentClass = ClassType.none;
  late Interpreter interpreter;

  Resolver(this.interpreter);

  void resolve(List<Stmt> statements) {
    for (final stmt in statements) {
      try {
        resolveStmt(stmt);
      } catch (e) {
        if (e is! ResolveError) {
          errors.add(ResolveError(e.toString(), 1));
        } else {
          errors.add(e);
        }
      }
    }
  }

  void resolveExpr(Expr expr) {
    expr.accept(this);
  }

  void resolveStmt(Stmt stmt) {
    stmt.accept(this);
  }

  void resolveBlock(List<Stmt> statements) {
    for (final stmt in statements) {
      resolveStmt(stmt);
    }
  }

  void resolveFunction(Fun stmt, FunctionType type) {
    final enclosingFunction = currentFunction;
    currentFunction = type;

    beginScope();
    for (Token param in stmt.params) { // AoS notjing to resolve here :D
      declare(param);
      define(param);
    }
    // AoS here,
    resolveContract(stmt);
    resolveBlock(stmt.body);
    endScope();

    currentFunction = enclosingFunction;
  }

  @override
  void visitPrintStmt(Print stmt) {
    resolveExpr(stmt.expression);
  }

  @override
  void visitReturnStmt(Return stmt) {
    if (currentFunction == FunctionType.none) {
      throw ResolveError(
          'Cannot return from top-level code', stmt.keyword.line);
    }

    if (stmt.value != null) {
      if (currentFunction == FunctionType.initializer) {
        throw ResolveError(
            'Cannot return value from initializer', stmt.keyword.line);
      }
      resolveExpr(stmt.value!);
    }
  }

  @override
  void visitBlockStmt(Block stmt) {
    beginScope();
    resolveBlock(stmt.statements);
    endScope();
  }

  @override
  void visitVarStmt(Var stmt) {
    declare(stmt.name);
    if (stmt.initializer != null) {
      resolveExpr(stmt.initializer!);
    }
    define(stmt.name);
  }

  @override
  void visitWhileStmt(While stmt) {
    resolveExpr(stmt.condition);
    resolveStmt(stmt.body);
  }

  @override
  void visitExpressionStmt(Expression stmt) {
    resolveExpr(stmt.expression);
  }

  @override
  void visitClassStmt(Class stmt) {
    ClassType enclosingClass = currentClass;
    currentClass = ClassType.klass;

    declare(stmt.name);
    define(stmt.name);

    if (stmt.superclass != null &&
        stmt.name.lexeme == stmt.superclass!.name.lexeme) {
      throw ResolveError('A class cannot inherit from itself.', stmt.name.line);
    }

    if (stmt.superclass != null) {
      currentClass = ClassType.subklass;
      resolveExpr(stmt.superclass!);
    }

    if (stmt.superclass != null) {
      beginScope();
      scopes.last["super"] = true;
    }

    beginScope();
    scopes.last["this"] = true;

    for (Fun method in stmt.methods) {
      FunctionType declaration = FunctionType.method;
      if (method.name.lexeme == 'init') {
        declaration = FunctionType.initializer;
      }
      resolveFunction(method, declaration);
    }

    endScope();

    if (stmt.superclass != null) {
      endScope();
    }

    currentClass = enclosingClass;
  }

  @override
  void visitFunStmt(Fun stmt) {
    declare(stmt.name);
    define(stmt.name);
    resolveFunction(stmt, FunctionType.function);
  }

  @override
  void visitIfStmt(If stmt) {
    resolveExpr(stmt.condition);
    resolveStmt(stmt.thenBranch);
    if (stmt.elseBranch != null) {
      resolveStmt(stmt.elseBranch!);
    }
  }

  @override
  void visitAssignExpr(Assign expr) {
    resolveExpr(expr.value);
    resolveLocal(expr, expr.name);
  }

  @override
  void visitBinaryExpr(Binary expr) {
    resolveExpr(expr.left);
    resolveExpr(expr.right);
  }

  @override
  void visitCallExpr(Call expr) {
    resolveExpr(expr.callee);
    for (Expr arg in expr.arguments) {
      resolveExpr(arg);
    }
  }

  @override
  void visitGetExpr(Get expr) {
    resolveExpr(expr.object);
  }

  @override
  void visitSetExpr(Set expr) {
    resolveExpr(expr.value);
    resolveExpr(expr.object);
  }

  @override
  void visitSuperExpr(Super expr) {
    if (currentClass == ClassType.none) {
      throw ResolveError(
          'Cannot use "super" outside of a class.', expr.name.line);
    } else if (currentClass != ClassType.subklass) {
      throw ResolveError(
          'Cannot use "super" in class with no superclass', expr.name.line);
    }
    resolveLocal(expr, expr.keyword);
  }

  @override
  void visitThisExpr(This expr) {
    if (currentClass == ClassType.none) {
      throw ResolveError(
          'Cannot use "this" outside a class.', expr.keyword.line);
    }
    resolveLocal(expr, expr.keyword);
  }

  @override
  void visitGroupingExpr(Grouping expr) {
    resolveExpr(expr.expression);
  }

  @override
  void visitUnaryExpr(Unary expr) {
    resolveExpr(expr.right);
  }

  @override
  void visitVariableExpr(Variable expr) {
    if (scopes.isNotEmpty && scopes.last[expr.name.lexeme] == false) {
      throw ResolveError(
          'Cannot read local variable in its own initializer', expr.name.line);
    }
    resolveLocal(expr, expr.name);
  }

  @override
  void visitLiteralExpr(Literal expr) {
    return;
  }

  @override
  void visitLogicalExpr(Logical expr) {
    resolveExpr(expr.left);
    resolveExpr(expr.right);
  }

  void declare(Token name) {
    if (scopes.isEmpty) return;
    if (scopes.last.containsKey(name.lexeme)) {
      throw ResolveError(
          'Already a variable with this name in this scope', name.line);
    }
    scopes.last[name.lexeme] = false; // AoS this and look below ...
  }

  void define(Token name) {
    if (scopes.isEmpty) return;
    scopes.last[name.lexeme] = true; // Aos can be speed up
  }

  void beginScope() {
    final Map<String, bool> scope = {};
    scopes.add(scope);
  }

  void endScope() {
    scopes.removeLast();
  }

  void resolveLocal(Expr expr, Token name) {
    for (int i = scopes.length - 1; i >= 0; i--) {
      if (scopes[i].containsKey(name.lexeme)) {
        interpreter.resolve(expr, (scopes.length - 1) - i);
      }
    }
  }

  @override
  void visitBreakStmt(Break break$) {
    resolveExpr(break$.expression);
  }

  @override
  void visitContractStmt(Contract cont) {
  // AoS dead code ... probably we do not need to visit Contracts
  }

  void resolveContract(Fun stmt) {
    Contract cont = stmt.contract;
    if (cont.require != null ) {
      for (var it in cont.require!) {
        resolveExpr(it);
      }
    }
    if (cont.ensure != null ) {
      for (var it in cont.ensure!) {
        resolveExpr(it);
      }
    }
    if (cont.invariant != null ) {
      for (var it in cont.invariant!) {
        resolveExpr(it);
      }
    }
  }
}

class ResolveError extends Error {
  final String description;
  final int line;

  ResolveError(this.description, this.line);
}
