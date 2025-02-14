import 'ast.dart';
import 'exception.dart';
import 'lexer.dart';
import 'token.dart';

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
