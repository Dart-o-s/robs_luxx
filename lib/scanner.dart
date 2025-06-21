import 'package:luxx_dart/token.dart';

class Scanner {
  final String input;
  final List<Token> tokens = [];
  final List<ScanError> errors = [];
  var lastComment = StringBuffer();

  int _pos = 0;
  int line = 1;

  final Map<String, TokenType> _keywords = {
    'a'  : TokenType.a,      // aos a, an, is and is_a are fancy end of line comments
    'an' : TokenType.an,
    'is' : TokenType.is$,
    'is_a' : TokenType.is_a, // aos in source code: 'is a' - probably do not need it

    'BRK' : TokenType.BRK,   // aos breaks into the monitor

    'in' : TokenType.in$,

    'and': TokenType.and,
    'class': TokenType.class$,
    'else': TokenType.else$,
    'false': TokenType.false$,
    'for': TokenType.for$,
    'fun': TokenType.fun,
    'if': TokenType.if$,
    'nil': TokenType.nil,
    'or': TokenType.or,
    'print': TokenType.print,
    'return': TokenType.return$,
    'super': TokenType.super$,
    'this': TokenType.this$,
    'true': TokenType.true$,
    'var': TokenType.var$,
    'while': TokenType.while$,
    // new tokens
    'require' : TokenType.require,
    'ensure' : TokenType.ensure,
    'invariant' : TokenType.invariant,

    '_meta::printAst': TokenType.printAst,
  };

  Scanner(this.input);

  List<Token> scan() {
    while (peek().isNotEmpty) {
      switch (peek()) {
        case ' ':
        case '\t':
          advance();
          break;

        case '\n':
          line++;
          advance();
          break;

        case '.':
          addToken(TokenType.dot, '.');
          advance();
          break;

        case ':':
          addToken(TokenType.colon, ':');
          advance();
          break;

        case ',':
          addToken(TokenType.comma, ',');
          advance();
          break;

        case '+':
          addToken(TokenType.plus, '+');
          advance();
          break;

        case '-':
          addToken(TokenType.minus, '-');
          advance();
          break;

        case '*':
          addToken(TokenType.star, '*');
          advance();
          break;

        case '{':
          addToken(TokenType.braceLeft, '{');
          advance();
          break;

        case '}':
          addToken(TokenType.braceRight, '}');
          advance();
          break;

        case '(':
          addToken(TokenType.parenLeft, '(');
          advance();
          break;

        case ')':
          addToken(TokenType.parenRight, ')');
          advance();
          break;

        case ';':
          addToken(TokenType.semicolon, ';');
          advance();
          break;

        case '%':
          addToken(TokenType.modulo, '%');
          advance();
          break;

        case '/':
          advance();
          if (peek() == '/') {
            comment();
          } else if (peek() == '*') {
            _advanceUntilCommentEnd();
          } else {
            addToken(TokenType.slash, '/');
          }
          break;

        case '<':
          advance();
          if (peek() == '=') {
            addToken(TokenType.lessEqual, '<=');
            advance();
          } else {
            addToken(TokenType.less, '<');
          }
          break;

        case '>':
          advance();
          if (peek() == '=') {
            addToken(TokenType.greaterEqual, '>=');
            advance();
          } else {
            addToken(TokenType.greater, '>');
          }
          break;

        case '=':
          advance();
          if (peek() == '=') {
            addToken(TokenType.equalEqual, '==');
            advance();
          } else {
            addToken(TokenType.equal, '=');
          }
          break;

        case '!':
          advance();
          if (peek() == '=') {
            addToken(TokenType.bangEqual, '!=');
            advance();
          } else {
            addToken(TokenType.bang, '!');
          }
          break;

        case '"':
          string();
          break;

        default:
          if (isNumeric()) {
            number();
          } else if (isAlphaNumeric()) {
            identifier();
          } else {
            /// Kanji can be parsed, it is just not in the range of idents
            /// sumerian are two ints, and the first one starts with d808
            // String w1= peekAsInt().toRadixString(16);
            // advance();
            // String w2= peekAsInt().toRadixString(16);
            // print ("Codes: $w1");
            errors.add(ScanError('Unexpected character "${peek()}" found', line));
            advance();
          }
      }
    }

    addToken(TokenType.eof, '');

    print("Amount of Tokens: ${tokens.length}");
    return tokens;
  }

  void addToken(TokenType type, String lexeme) {
    tokens.add(Token(type: type, lexeme: lexeme, line: line));
  }

  void comment() {
    lastComment.clear();
    do {
      lastComment.write(peek());
      advance();
    } while (peek().isNotEmpty && peek() != '\n');
  }

  void string() {
    advance();

    String value = '';
    while (peek().isNotEmpty && peek() != '"') {
      value += peek();
      advance();
    }

    if (peek().isEmpty) {
      errors.add(ScanError('Closing \'"\' expected', line));
    } else {
      advance();
    }

    tokens.add(Token(
        type: TokenType.string, lexeme: '"$value"', value: value, line: line));
  }

  void number() {
    String value = '';
    bool hasDecimal = false;

    do {
      value += peek();
      advance();

      if (!isNumeric()) {
        if (peek() == '.' && !hasDecimal) {
          hasDecimal = true;
        } else {
          break;
        }
      }
    } while (peek().isNotEmpty);

    tokens.add(Token(
        type: TokenType.number,
        lexeme: value,
        value: double.parse(value),
        line: line));
  }

  void identifier() {
    String value = '';

    do {
      value += peek();
      advance();
    } while (peek().isNotEmpty && (isAlphaNumeric() || peek() == ':'));

    TokenType? type = _keywords[value];
    if (type != null) {
      var tt = Token(type: type, lexeme: value, line: line);
      handleMetaToken(tt);
      tt.isKeyword = true;
      tokens.add(tt);
    } else {
      type ??= TokenType.identifier;
      tokens.add(Token(type: type, lexeme: value, line: line));
    }
  }

  void advance() {
    _pos++;
  }

  int peekAsInt() {
    int i = input.codeUnitAt(_pos);
    return i;
  }

  String peek() {
    if (isOutOfRange()) {
      return '';
    } else {
      return input[_pos];
    }
  }

  bool isOutOfRange() {
    return _pos >= input.length;
  }

  bool isNumeric() {
    return int.tryParse(peek()) != null;
  }

  bool isAlphaNumeric() {
    final alphanumeric = RegExp(r'^[_a-zA-Z0-9]+$');
    return alphanumeric.hasMatch(peek());
  }

  void handleMetaToken(Token tt) {
    if (tt.lexeme.startsWith("_meta::")) {
      comment();
      tt.eolComment = lastComment.toString();
    }
  }

  bool _match(String expected) {
    if (isOutOfRange() || peek() != expected) {
      return false;
    } else {
      _pos++;
      return true;
    }
  }

  // lox and luxx supports nested multi line comments
  void _advanceUntilCommentEnd() {
    int commentLevel = 1;
    int lastOpening = line; // + 1; // no idea why it is reported 1 to less

    advance(); // we are standing on the '*'
    while (commentLevel > 0 && !isOutOfRange()) {
      if (_match('\n')) {
        line++;
        continue;
      } else if (_match('/') && peek() == '*') {
        commentLevel = commentLevel + 1;
        lastOpening = line;
      } else if (_match('*') && peek() == '/') {
        commentLevel = commentLevel - 1;
      }
      advance();
    }
    if (isOutOfRange() && commentLevel != 0)
      errors.add(ScanError('Closing "*/" expected. Last opening "/*" at line: ${lastOpening} - my _pos: ${_pos}', line));

  }
}

class ScanError extends Error {
  final String description;
  final int line;

  ScanError(this.description, this.line);
}
