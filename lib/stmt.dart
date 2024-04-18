import 'package:lox_dart/lox_dart.dart';

abstract class Stmt {
  T accept<T>(StmtVisitor<T> visitor);
}

mixin StmtVisitor<T> {
  T visitBlockStmt(Block stmt);
  T visitClassStmt(Class stmt);
  T visitExpressionStmt(Expression stmt);
  T visitFunStmt(Fun stmt);
  T visitIfStmt(If stmt);
  T visitPrintStmt(Print stmt);
  T visitReturnStmt(Return stmt);
  T visitVarStmt(Var stmt);
  T visitWhileStmt(While stmt);
}

class Block extends Stmt {
  Block(this.statements);
  final List<Stmt> statements;

  @override
  T accept<T>(StmtVisitor<T> visitor) {
    return visitor.visitBlockStmt(this);
  }
}

class Class extends Stmt {
  Class(this.name,this.methods);
  final Token name;
  final List<Fun> methods;

  @override
  T accept<T>(StmtVisitor<T> visitor) {
    return visitor.visitClassStmt(this);
  }
}

class Expression extends Stmt {
  Expression(this.expression);
  final Expr expression;

  @override
  T accept<T>(StmtVisitor<T> visitor) {
    return visitor.visitExpressionStmt(this);
  }
}

class Fun extends Stmt {
  Fun(this.name,this.params,this.body);
  final Token name;
  final List<Token> params;
  final List<Stmt> body;

  @override
  T accept<T>(StmtVisitor<T> visitor) {
    return visitor.visitFunStmt(this);
  }
}

class If extends Stmt {
  If(this.condition,this.thenBranch,this.elseBranch);
  final Expr condition;
  final Stmt thenBranch;
  final Stmt? elseBranch;

  @override
  T accept<T>(StmtVisitor<T> visitor) {
    return visitor.visitIfStmt(this);
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

class Return extends Stmt {
  Return(this.keyword,this.value);
  final Token keyword;
  final Expr? value;

  @override
  T accept<T>(StmtVisitor<T> visitor) {
    return visitor.visitReturnStmt(this);
  }
}

class Var extends Stmt {
  Var(this.name,this.initializer);
  final Token name;
  final Expr? initializer;

  @override
  T accept<T>(StmtVisitor<T> visitor) {
    return visitor.visitVarStmt(this);
  }
}

class While extends Stmt {
  While(this.condition,this.body);
  final Expr condition;
  final Stmt body;

  @override
  T accept<T>(StmtVisitor<T> visitor) {
    return visitor.visitWhileStmt(this);
  }
}

