import 'dart:ffi';
import 'dart:math';

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

class UnknownException implements Exception {}

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

abstract interface class Visitor<T> {
  T _visitIntegerNode(IntegerNode node);

  T _visitRealNode(RealNode node);

  T _visitBinaryNode(BinaryNode node);

  T _visitUnaryNode(UnaryNode node);
}

abstract class Node {}

enum NumberType { Real, Integer }

class LexerException extends FormatException {
  LexerException({required message}) : super(message);
}

class NumberNode extends Node {
  final NumberType type;

  NumberNode({
    required this.type,
  });
}

class IntegerNode extends NumberNode {
  final int value;

  IntegerNode({
    required this.value,
  }) : super(type: NumberType.Integer);

  @override
  String toString() {
    return 'IntegerNode{value: $value}';
  }
}

class RealNode extends NumberNode {
  final double value;

  RealNode({
    required this.value,
  }) : super(type: NumberType.Real);

  @override
  String toString() {
    return 'RealNode{value: $value}';
  }
}

class BinaryNode extends Node {
  final Node left;
  final Operator operator;
  final Node right;

  BinaryNode({
    required this.left,
    required this.operator,
    required this.right,
  });
}

class UnaryNode extends Node {
  final Operator operator;
  final Node right;

  UnaryNode({
    required this.operator,
    required this.right,
  });
}

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

class ParserException implements Exception {
  final String message;

  ParserException(this.message);
}

class Parser {
  final Lexer _lexer;
  late Token _currentToken;

  Parser({
    required Lexer lexer,
  })  : _lexer = lexer,
        _currentToken = lexer.nextToken();

  Node parse() {
    return _expr();
  }

  Node _expr() {
    var node = _term();
    if (_currentToken.type == TokenType.PLUS) {
      _consume();
      var right = _term();
      return BinaryNode(left: node, operator: Operator.PLUS, right: right);
    }
    if (_currentToken.type == TokenType.MINUS) {
      _consume();
      var right = _term();
      return BinaryNode(left: node, operator: Operator.MINUS, right: right);
    }
    return node;
  }

  Node _term() {
    var node = _factor();
    if (_currentToken.type == TokenType.MUL) {
      _consume();
      var right = _factor();
      return BinaryNode(left: node, operator: Operator.MUL, right: right);
    }
    if (_currentToken.type == TokenType.DIV) {
      _consume();
      var right = _factor();
      return BinaryNode(left: node, operator: Operator.DIV, right: right);
    }
    return node;
  }

  void _consume() {
    _currentToken = _lexer.nextToken();
  }

  Node _factor() {
    switch (_currentToken.type) {
      case TokenType.PLUS:
        _consume();
        var right = _factor();
        return UnaryNode(operator: Operator.PLUS, right: right);
      case TokenType.MINUS:
        _consume();
        var right = _factor();
        return UnaryNode(operator: Operator.MINUS, right: right);
      case TokenType.LPAREN:
        _consume();
        var node = _expr();
        if (_currentToken.type != TokenType.RPAREN) {
          throw ParserException("""
        want ')', got '${_currentToken.value}'
        """
              .trim());
        }
        _consume();
        return node;
      case TokenType.NUMBER:
        if (_currentToken.value.contains('.')) {
          var realNode = RealNode(value: double.parse(_currentToken.value));
          _consume();
          return realNode;
        } else {
          var integerNode = IntegerNode(value: int.parse(_currentToken.value));
          _consume();
          return integerNode;
        }
      default:
        throw UnknownException();
    }
  }
}

class InterpreterException implements Exception {}

class Interpreter implements Visitor<num> {
  num interpret(Node node) {
    switch (node) {
      case BinaryNode binaryNode:
        return _visitBinaryNode(binaryNode);
      case UnaryNode unaryNode:
        return _visitUnaryNode(unaryNode);
      case IntegerNode integerNode:
        return _visitIntegerNode(integerNode);
      case RealNode realNode:
        return _visitRealNode(realNode);
    }
    throw InterpreterException();
  }

  @override
  num _visitBinaryNode(BinaryNode node) {
    var leftValue = interpret(node.left);
    var rightValue = interpret(node.right);
    switch (node.operator) {
      case Operator.PLUS:
        return leftValue + rightValue;
      case Operator.MINUS:
        return leftValue - rightValue;
      case Operator.MUL:
        return leftValue * rightValue;
      case Operator.DIV:
        return leftValue / rightValue;
    }
  }

  @override
  num _visitIntegerNode(IntegerNode node) {
    return node.value;
  }

  @override
  num _visitRealNode(RealNode node) {
    return node.value;
  }

  @override
  num _visitUnaryNode(UnaryNode node) {
    switch (node.operator) {
      case Operator.PLUS:
        return interpret(node.right);
      case Operator.MINUS:
        return -interpret(node.right);
      default:
        throw InterpreterException();
    }
  }
}
