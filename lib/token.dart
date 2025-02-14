enum TokenType {
  NUMBER,
  PLUS,
  MINUS,
  MUL,
  DIV,
  LPAREN,
  RPAREN,
  EOF,
}

enum Operator {
  PLUS,
  MINUS,
  MUL,
  DIV,
}


class Token {
  final TokenType type;
  final String value;

  const Token({required this.type, required this.value});

  Token.plus()
      : type = TokenType.PLUS,
        value = '+';

  Token.minus()
      : type = TokenType.MINUS,
        value = '-';

  Token.lparen()
      : type = TokenType.LPAREN,
        value = '(';

  Token.rparen()
      : type = TokenType.RPAREN,
        value = ')';

  Token.mul()
      : type = TokenType.MUL,
        value = '*';

  Token.div()
      : type = TokenType.DIV,
        value = '/';

  Token.eof()
      : type = TokenType.EOF,
        value = 'EOF';

  Token.number(this.value) : type = TokenType.NUMBER;

  @override
  String toString() {
    return 'Token($type, $value)';
  }
}
