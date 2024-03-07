enum TokenType {
  bang,
  bangEqual,
  braceLeft,
  braceRight,
  boolean,
  comment,
  division,
  equal,
  equalEqual,
  greater,
  greaterEqual,
  identifier,
  kwAnd,
  kwFalse,
  kwFor,
  kwFun,
  kwIf,
  kwNil,
  kwOr,
  kwPrint,
  kwReturn,
  kwTrue,
  kwVar,
  kwWhile,
  less,
  lessEqual,
  minus,
  nil,
  number,
  parenLeft,
  parenRight,
  plus,
  product,
  semicolon,
  string,
  eof
}

class Token {
  final TokenType type;
  final String lexeme;
  final int line;
  final Object? value;

  Token({required this.type, required this.lexeme, required this.line, this.value});

  @override
  String toString() {
    return '<${type.name} $lexeme $value>';
  }
}
