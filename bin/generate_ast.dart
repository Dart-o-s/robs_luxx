import 'dart:io';

void main(List<String> arguments) {
  if (arguments.length != 1) {
    print('Usage: generate_ast <output directory>');
    exit(64);
  }

  String outputDir = arguments[0];

  defineAst(outputDir, "Expr", [
    "Assign: Token name, Expr value",
    "Binary: Expr left, Token operator, Expr right",
    "Grouping: Expr expression",
    "Literal: Object? value",
    "Unary: Token operator, Expr right",
    "Variable: Token name",
  ]);
  defineAst(outputDir, "Stmt", [
    "Block: List<Stmt> statements",
    "Expression: Expr expression",
    "If: Expr condition, Stmt thenBranch, Stmt? elseBranch",
    "Print: Expr expression",
    "Var: Token name, Expr? initializer",
  ]);
}

void defineAst(String outputDir, String baseName, List<String> types) {
  String path = '$outputDir/${baseName.toLowerCase()}.dart';
  final file = File(path);
  final sink = file.openWrite();
  sink.writeln('import \'package:lox_dart/lox_dart.dart\';');
  sink.writeln();
  sink.writeln('abstract class $baseName {');
  sink.writeln('  T accept<T>(${baseName}Visitor<T> visitor);');
  sink.writeln('}');
  sink.writeln();
  defineVisitor(sink, baseName, types);
  sink.writeln();

  for (String type in types) {
    String className = type.split(':')[0].trim();
    Iterable<String> fieldList =
        type.split(':')[1].trim().split(',').map((field) => field.trim());
    defineType(sink, baseName, className, fieldList);
    sink.writeln();
  }

  sink.close();
}

void defineVisitor(IOSink sink, String baseName, List<String> types) {
  sink.writeln('mixin ${baseName}Visitor<T> {');

  for (String type in types) {
    String typeName = type.split(':')[0].trim();
    sink.writeln(
        '  T visit$typeName$baseName($typeName ${baseName.toLowerCase()});');
  }

  sink.writeln('}');
}

void defineType(IOSink sink, String baseName, String className,
    Iterable<String> fieldList) {
  sink.writeln('class $className extends $baseName {');

  List<String> params =
      fieldList.map((element) => 'this.${element.split(' ')[1]}').toList();
  sink.writeln('  $className(${params.join(',')});');

  for (String field in fieldList) {
    sink.writeln('  final $field;');
  }

  sink.writeln();
  sink.writeln('  @override');
  sink.writeln('  T accept<T>(${baseName}Visitor<T> visitor) {');
  sink.writeln('    return visitor.visit$className$baseName(this);');
  sink.writeln('  }');

  sink.writeln('}');
}
