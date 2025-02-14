
import 'exception.dart';
import 'token.dart';

class Lexer {
  final String _text;
  int _position = 0;

  Lexer({
    required String text,
  }) : _text = text;

  String get _char => _text[_position];

  bool get _ended => _position >= _text.length;

  bool _isDigit() {
    if (_ended) return false;
    var charCode = _char.codeUnitAt(0);
    return charCode >= 48 && charCode <= 57;
  }

  void _advance() {
    _position++;
  }

  void _skipWhiteSpaces() {
    if (_ended) return;
    if (_char == " " || _char == "\n" || _char == "\r" || _char == "\t") {
      _advance();
    }
  }

  Token nextToken() {
    _skipWhiteSpaces();
    while (!_ended) {
      switch (_char) {
        case "+":
          _advance();
          return Token.plus();
        case "-":
          _advance();
          return Token.minus();
        case "*":
          _advance();
          return Token.mul();
        case "/":
          _advance();
          return Token.div();
        case "(":
          _advance();
          return Token.lparen();
        case ")":
          _advance();
          return Token.rparen();
        default:
          _skipWhiteSpaces();
          if (_isDigit()) {
            var buffer = <String>[];
            while (_isDigit()) {
              buffer.add(_char);
              _advance();
            }
            if (!_ended) {
              if (_char == '.') {
                buffer.add('.');
                _advance();
                while (_isDigit()) {
                  buffer.add(_char);
                  _advance();
                }
              }
            }
            return Token.number(buffer.join(""));
          } else {
            if (_ended) {
              return Token.eof();
            }
            throw LexerException(message: _char);
          }
      }
    }
    return Token.eof();
  }
}
