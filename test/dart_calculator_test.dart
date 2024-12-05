import 'package:dart_calculator/dart_calculator.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([Lexer, Parser])
import 'dart_calculator_test.mocks.dart';

void main() {
  group("Lexer tests", () {
    test('Plus', () {
      var lexer = Lexer(text: " + ");
      var token = lexer.nextToken();
      expect(token.type, TokenType.PLUS);
      expect(token.value, '+');
    });
    test('Minus', () {
      var lexer = Lexer(text: " - ");
      var token = lexer.nextToken();
      expect(token.type, TokenType.MINUS);
      expect(token.value, '-');
    });
    test('Mul', () {
      var lexer = Lexer(text: " * ");
      var token = lexer.nextToken();
      expect(token.type, TokenType.MUL);
      expect(token.value, '*');
    });

    test('Div', () {
      var lexer = Lexer(text: ' / ');
      var token = lexer.nextToken();
      expect(token.type, TokenType.DIV);
      expect(token.value, '/');
    });

    test('LPAREN', () {
      var lexer = Lexer(text: ' ( ');
      var token = lexer.nextToken();
      expect(token.type, TokenType.LPAREN);
      expect(token.value, '(');
    });

    test('RPAREN', () {
      var lexer = Lexer(text: ' ) ');
      var token = lexer.nextToken();
      expect(token.type, TokenType.RPAREN);
      expect(token.value, ')');
    });

    test('Integer', () {
      var lexer = Lexer(text: ' 123 ');
      var token = lexer.nextToken();
      expect(token.type, TokenType.NUMBER);
      expect(token.value, '123');
    });

    test('REAL', () {
      var lexer = Lexer(text: ' 1.23 ');
      var token = lexer.nextToken();
      expect(token.type, TokenType.NUMBER);
      expect(token.value, '1.23');
    });
    test('Error', () {
      var lexer = Lexer(text: ' abc ');
      expect(() => lexer.nextToken(), throwsA(isA<LexerException>()));
    });
    test('EOF', () {
      var lexer = Lexer(text: '  ');
      var token = lexer.nextToken();
      expect(token.type, TokenType.EOF);
      expect(token.value, 'EOF');
    });
  });

  group('Parser', () {
    test('parse integer', () {
      var lexer = MockLexer();
      when(lexer.nextToken())
          .thenReturnInOrder([Token.number('1'), Token.eof()]);
      var parser = Parser(lexer: lexer);
      var node = parser.parse();
      expect(node, isA<IntegerNode>());
      var numberNode = node as IntegerNode;
      expect(numberNode.value, equals(1));
    });

    test('parse real', () {
      var lexer = MockLexer();
      when(lexer.nextToken())
          .thenReturnInOrder([Token.number('1.1'), Token.eof()]);
      var parser = Parser(lexer: lexer);
      var node = parser.parse();
      expect(node, isA<RealNode>());
      var realNode = node as RealNode;
      expect(realNode.value, equals(1.1));
    });

    test('parse minus integer', () {
      var lexer = MockLexer();
      when(lexer.nextToken()).thenReturnInOrder([
        Token.minus(),
        Token.number('1'),
        Token.eof(),
      ]);
      var parser = Parser(lexer: lexer);
      var node = parser.parse();
      expect(node, isA<UnaryNode>());
      var unaryNode = node as UnaryNode;
      expect(unaryNode.operator, equals(Operator.MINUS));
      expect(unaryNode.right, isA<IntegerNode>());
      var integerNode = unaryNode.right as IntegerNode;
      expect(integerNode.value, equals(1));
    });

    test('parse plus real', () {
      var lexer = MockLexer();
      when(lexer.nextToken()).thenReturnInOrder([
        Token.plus(),
        Token.number('1.0'),
        Token.eof(),
      ]);
      var parser = Parser(lexer: lexer);
      var node = parser.parse();
      expect(node, isA<UnaryNode>());
      var unaryNode = node as UnaryNode;
      expect(unaryNode.operator, equals(Operator.PLUS));
      expect(unaryNode.right, isA<RealNode>());
      var realNode = unaryNode.right as RealNode;
      expect(realNode.value, equals(1.0));
    });

    test('parse binary + with integers', () {
      var lexer = MockLexer();
      when(lexer.nextToken()).thenReturnInOrder([
        Token.number('1'),
        Token.plus(),
        Token.number('2'),
        Token.eof(),
      ]);
      var parser = Parser(lexer: lexer);
      var node = parser.parse();
      expect(node, isA<BinaryNode>());
      var binaryNode = node as BinaryNode;
      expect(binaryNode.operator, equals(Operator.PLUS));
      expect(binaryNode.left, isA<IntegerNode>());
      expect(binaryNode.right, isA<IntegerNode>());
      var leftNode = binaryNode.left as IntegerNode;
      expect(leftNode.value, equals(1));
      var rightNode = binaryNode.right as IntegerNode;
      expect(rightNode.value, equals(2));
    });

    test('parse binary - with reals', () {
      var lexer = MockLexer();
      when(lexer.nextToken()).thenReturnInOrder([
        Token.number('1.1'),
        Token.minus(),
        Token.number('2.2'),
        Token.eof(),
      ]);
      var parser = Parser(lexer: lexer);
      var node = parser.parse();
      expect(node, isA<BinaryNode>());
      var binaryNode = node as BinaryNode;
      expect(binaryNode.operator, equals(Operator.MINUS));
      expect(binaryNode.left, isA<RealNode>());
      expect(binaryNode.right, isA<RealNode>());
      var leftNode = binaryNode.left as RealNode;
      expect(leftNode.value, equals(1.1));
      var rightNode = binaryNode.right as RealNode;
      expect(rightNode.value, equals(2.2));
    });

    group('Interpreter tests', () {
      test('parse integer', (){
        var parser = MockParser();
        when(parser.parse()).thenReturn(IntegerNode(value: 1));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
       expect(num, equals(1));
      });

      test('parse real', (){
        var parser = MockParser();
        when(parser.parse()).thenReturn(RealNode(value: 1.1));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        expect(num, equals(1.1));
      });

      test('parse unary -> plus integer', (){
        var parser = MockParser();
        when(parser.parse()).thenReturn(UnaryNode(operator: Operator.PLUS, right: IntegerNode(value: 2)));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        expect(num, equals(2));
      });

      test('parse unary -> minus real', (){
        var parser = MockParser();
        when(parser.parse()).thenReturn(UnaryNode(operator: Operator.MINUS, right: RealNode(value: 2.0)));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        expect(num, equals(-2.0));
      });

      test('parse binary -> plus integers', (){
        var parser = MockParser();
        when(parser.parse()).thenReturn(BinaryNode(left: IntegerNode(value: 1), operator: Operator.PLUS, right: IntegerNode(value: 2)));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        expect(num, equals(3));
      });

      test('parse binary -> minus integers', (){
        var parser = MockParser();
        when(parser.parse()).thenReturn(BinaryNode(left: IntegerNode(value: 1), operator: Operator.MINUS, right: IntegerNode(value: 2)));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        expect(num, equals(-1));
      });

      test('parse binary -> mul integers', (){
        var parser = MockParser();
        when(parser.parse()).thenReturn(BinaryNode(left: IntegerNode(value: 2), operator: Operator.MUL, right: IntegerNode(value: 1)));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        expect(num, equals(2));
      });

      test('parse binary -> div integers', (){
        var parser = MockParser();
        when(parser.parse()).thenReturn(BinaryNode(left: IntegerNode(value: 2), operator: Operator.DIV, right: IntegerNode(value: 1)));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        expect(num, equals(2));
      });
    });
  });
}
