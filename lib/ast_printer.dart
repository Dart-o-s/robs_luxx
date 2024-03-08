import 'package:lox_dart/expr.dart' as xp;

class AstPrinter extends xp.Visitor<String> {
  String print(xp.Expr expr) {
    return expr.accept(this);
  }

  @override
  String visitBinaryExpr(xp.Binary expr) {
    return _parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitGroupingExpr(xp.Grouping expr) {
    return _parenthesize("group", [expr.expression]);
  }

  @override
  String visitLiteralExpr(xp.Literal expr) {
    if (expr.value == null) {
      return "nil";
    } else {
      return expr.value.toString();
    }
  }

  @override
  String visitUnaryExpr(xp.Unary expr) {
    return _parenthesize(expr.operator.lexeme, [expr.right]);
  }

  String _parenthesize(String name, List<xp.Expr> exprs) {
    final buffer = StringBuffer();

    buffer.write('(');
    buffer.write(name);
    for (xp.Expr expr in exprs) {
      buffer.write(' ');
      buffer.write(expr.accept(this));
    }
    buffer.write(')');

    return buffer.toString();
  }
}
