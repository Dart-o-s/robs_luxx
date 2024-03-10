import 'package:lox_dart/lox_dart.dart';

abstract class Stmt {
  T accept<T>(StmtVisitor<T> visitor);
}

mixin StmtVisitor<T> {
  T visitExpressionStmt(Expression stmt);
  T visitPrintStmt(Print stmt);
}

class Expression extends Stmt {
  Expression(this.expression);
  final Expr expression;

  @override
  T accept<T>(StmtVisitor<T> visitor) {
    return visitor.visitExpressionStmt(this);
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

