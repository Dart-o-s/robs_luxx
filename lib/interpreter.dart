import 'package:lox_dart/expr.dart' as xp;
import 'package:lox_dart/lox_dart.dart';

class Interpreter extends xp.Visitor<Object?> {
  List<InterpretError> errors = [];

  Object? interpret(xp.Expr expr) {
    Object? result;

    try {
      result = expr.accept(this);
    } catch (e) {
      if (e is! InterpretError) {
        errors.add(InterpretError(e.toString(), 1));
      } else {
        errors.add(e);
      }
      return null;
    }

    return result;
  }

  @override
  Object? visitBinaryExpr(xp.Binary expr) {
    final left = interpret(expr.left);
    final right = interpret(expr.right);

    switch (expr.operator.type) {
      case TokenType.plus:
        if (left is double && right is double) {
          return left + right;
        }
        if (left is String && right is String) {
          return left + right;
        }
        throw InterpretError(
            'Both values must be string or number', expr.operator.line);

      case TokenType.minus:
        if (left is double && right is double) {
          return left - right;
        }
        throw InterpretError('Both values must be number', expr.operator.line);

      case TokenType.star:
        if (left is double && right is double) {
          return left * right;
        }
        throw InterpretError('Both values must be number', expr.operator.line);

      case TokenType.slash:
        if (left is double && right is double) {
          return left / right;
        }
        throw InterpretError('Both values must be number', expr.operator.line);

      case TokenType.greater:
        if (left is double && right is double) {
          return left > right;
        }
        throw InterpretError('Both values must be number', expr.operator.line);

      case TokenType.greaterEqual:
        if (left is double && right is double) {
          return left >= right;
        }
        throw InterpretError('Both values must be number', expr.operator.line);

      case TokenType.less:
        if (left is double && right is double) {
          return left < right;
        }
        throw InterpretError('Both values must be number', expr.operator.line);

      case TokenType.lessEqual:
        if (left is double && right is double) {
          return left <= right;
        }
        throw InterpretError('Both values must be number', expr.operator.line);

      case TokenType.equalEqual:
        return _isEqual(left, right);

      case TokenType.bangEqual:
        return !_isEqual(left, right);

      default:
        throw InterpretError('Unrecognized expression', expr.operator.line);
    }
  }

  @override
  Object? visitGroupingExpr(xp.Grouping expr) {
    return interpret(expr.expression);
  }

  @override
  Object? visitUnaryExpr(xp.Unary expr) {
    final right = interpret(expr.right);

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
  Object? visitLiteralExpr(xp.Literal expr) {
    return expr.value;
  }

  bool _isTruthy(Object? object) {
    if (object == null) return false;
    if (object is bool) return object;
    return true;
  }

  bool _isEqual(Object? a, Object? b) {
    if (a == null && b == null) return true;
    if (a == null) return false;
    return a == b;
  }
}

class InterpretError extends Error {
  final String description;
  final int line;

  InterpretError(this.description, this.line);
}
