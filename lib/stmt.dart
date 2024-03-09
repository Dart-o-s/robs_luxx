import 'package:lox_dart/lox_dart.dart';

abstract class Stmt {
  T accept<T>(StmtVisitor<T> visitor);
}

abstract class StmtVisitor<T> {
  T visitExprStmtStmt(ExprStmt stmt);
  T visitPrintStmt(Print stmt);
}

class ExprStmt extends Stmt {
  ExprStmt(this.expression);
  final Expr expression;

  @override
  T accept<T>(StmtVisitor<T> visitor) {
    return visitor.visitExprStmtStmt(this);
  }
}

class Print extends Stmt {
  Print(this.expression);
  final Expr expression;

  @override
  T accept<T>(StmtVisitor<T> visitor) {
    return visitor.visitPrintStmt(this);
  }
}

