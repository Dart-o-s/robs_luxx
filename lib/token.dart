// do not add tokens in the middle (even if it looks as it makes sense on the first glance)
// see comment at the end of this enum!!
enum TokenType {
  and,

  a, // we only need one token type I think, but several lexems
  an,
  BRK,

  bang,
  bangEqual,
  braceLeft,
  braceRight,
  boolean,
  class$,
  comma,
  comment,
  dot,
  equal,
  equalEqual,
  else$,
  eof,
  false$,
  for$,
  fun,
  greater,
  greaterEqual,
  identifier,
  if$,

  in$,
  is$,
  is_a,

  less,
  lessEqual,
  minus,

  modulo,

  nil,
  number,
  or,
  parenLeft,
  parenRight,
  plus,
  print,
  return$,
  semicolon,
  star,
  slash,
  string,
  super$,
  this$,
  true$,
  var$,
  while$,
  printAst,

  require,
  ensure,
  invariant,

  colon,
  // add new tokens above. At some point we might persist the token stream
  // that means the "order" and hence their numeric value has to stay the same
}

class Token {
  final TokenType type;
  final String lexeme;
  final int line;
  final Object? value;

  String leadingComment = "";

  /// also used for meta tokens as argument
  String eolComment = "";

  bool isKeyword = false;

  Token({required this.type, required this.lexeme, required this.line, this.value});

  @override
  String toString() {
    return '<${type.name} $lexeme $value>';
  }
}
