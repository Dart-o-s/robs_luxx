import 'package:lox_dart/ast_printer.dart';
import 'package:lox_dart/lox_dart.dart';

void main(List<String> arguments) {
  Expr expression = Binary(
      Unary(Token(type: TokenType.minus, lexeme: '-', line: 1), Literal(123)),
      Token(type: TokenType.product, lexeme: '*', line: 1),
      Grouping(Literal(45.67)));

  print(AstPrinter().print(expression));
}
