import 'package:lox_dart/lox_dart.dart';

class Resolver with ExprVisitor<void>, StmtVisitor<void> {
  List<ResolveError> errors = [];
  final List<Map<String, bool>> scopes = [];
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
    beginScope();
    for (final stmt in statements) {
      resolveStmt(stmt);
    }
    endScope();
  }

  @override
  void visitPrintStmt(Print stmt) {
    resolveExpr(stmt.expression);
  }

  @override
  void visitReturnStmt(Return stmt) {
    if (stmt.value != null) {
      resolveExpr(stmt.value!);
    }
  }

  @override
  void visitBlockStmt(Block stmt) {
    resolveBlock(stmt.statements);
  }

  @override
  void visitVarStmt(Var stmt) {
    declare(stmt.name);
    define(stmt.name);
    if (stmt.initializer != null) {
      resolveExpr(stmt.initializer!);
    }
  }

  @override
  void visitWhileStmt(While stmt) {
    resolveExpr(stmt.condition);
    beginScope();
    resolveStmt(stmt.body);
    endScope();
  }

  @override
  void visitExpressionStmt(Expression stmt) {
    resolveExpr(stmt.expression);
  }

  @override
  void visitFunStmt(Fun stmt) {
    declare(stmt.name);
    define(stmt.name);

    beginScope();
    resolveBlock(stmt.body);
    endScope();
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
    if (scopes.isEmpty || !scopes.last.containsKey(expr.name.lexeme) || scopes.last.containsKey(expr.name.lexeme) == false) {
      throw ResolveError('Var cannot assign to itself', expr.name.line);
    }

    resolveExpr(expr.value);
  }

  @override
  void visitBinaryExpr(Binary expr) {
    resolveExpr(expr.left);
    resolveExpr(expr.right);
  }

  @override
  void visitCallExpr(Call expr) {
    resolveExpr(expr.callee);
    beginScope();
    for (Expr arg in expr.arguments) {
      resolveExpr(arg);
    }
    endScope();
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
    resolveLocal(expr);
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
    final scope = scopes.last;
    scope[name.lexeme] = false;
  }

  void define(Token name) {
    final scope = scopes.last;
    scope[name.lexeme] = true;
  }

  void beginScope() {
    final Map<String, bool> scope = {};
    scopes.add(scope);
  }

  void endScope() {
    scopes.removeLast();
  }

  void resolveLocal(Variable variable) {
    for (int i = 0; i < scopes.length; i++) {
      if (i > 0 && scopes[i].containsKey(variable.name.lexeme)) {
        interpreter.resolve(variable, i);
      }
    }
  }
}

class ResolveError extends Error {
  final String description;
  final int line;

  ResolveError(this.description, this.line);
}
