import 'ast.dart';
import 'exception.dart';
import 'lexer.dart';
import 'token.dart';

enum Preference {
  lowest,
  number,
  sum,
  product,
  paren,
}

extension on Preference {
  bool greaterThan(Preference other) {
    return index - other.index > 0;
  }
}

extension on TokenType {
  Preference getPreference() {
    switch (this) {
      case TokenType.NUMBER:
        return Preference.number;
      case TokenType.PLUS:
        return Preference.sum;
      case TokenType.MINUS:
        return Preference.sum;
      case TokenType.MUL:
        return Preference.product;
      case TokenType.DIV:
        return Preference.product;
      case TokenType.LPAREN:
        return Preference.paren;
      case TokenType.RPAREN:
        return Preference.lowest;
      case TokenType.EOF:
        return Preference.paren;
    }
  }
}

/*

expr : factor

* */
class Parser {
  final Lexer _lexer;
  late Token _currentToken;

  Parser({
    required Lexer lexer,
  })  : _lexer = lexer,
        _currentToken = lexer.nextToken();

  Node parse() {
    return _parseExpression();
  }

  void _consume() {
    _currentToken = _lexer.nextToken();
  }

  Node _parsePrimary() {
    switch (_currentToken.type) {
      case TokenType.PLUS:
        var pref = _currentToken.type.getPreference();
        _consume();
        var right = _parseBinary(pref);
        return UnaryNode(operator: Operator.PLUS, right: right);
      case TokenType.MINUS:
        var pref = _currentToken.type.getPreference();
        _consume();
        var right = _parseBinary(pref);
        return UnaryNode(operator: Operator.MINUS, right: right);
      case TokenType.LPAREN:
        _consume();
        var node = _parseBinary(Preference.lowest);
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

  Node _parseExpression() {
    var node = _parseBinary(Preference.lowest);
    return node;
  }

  Node _parseBinary(Preference pref) {
    var left = _parsePrimary();
    while (_currentToken.type != TokenType.EOF &&
        _currentToken.type.getPreference().greaterThan(pref)) {
      var curTokenType = _currentToken.type;
      _consume();
      var nextPref = curTokenType.getPreference();
      var right = _parseBinary(nextPref);
      left = applyOperator(curTokenType, left, right);
    }
    return left;
  }

  Node applyOperator(TokenType tokenType, Node left, Node right) {
    switch (tokenType) {
      case TokenType.PLUS:
        return BinaryNode(left: left, operator: Operator.PLUS, right: right);
      case TokenType.MINUS:
        return BinaryNode(left: left, operator: Operator.MINUS, right: right);
      case TokenType.MUL:
        return BinaryNode(left: left, operator: Operator.MUL, right: right);
      case TokenType.DIV:
        return BinaryNode(left: left, operator: Operator.DIV, right: right);
      default:
        throw UnimplementedError();
    }
  }
}
