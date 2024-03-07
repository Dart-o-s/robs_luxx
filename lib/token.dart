enum TokenTypes {
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
  final TokenTypes type;
  final String lexeme;
  final Object? value;

  Token({required this.type, required this.lexeme, this.value});

  @override
  String toString() {
    return '<$type - $lexeme : $value>';
  }
}
