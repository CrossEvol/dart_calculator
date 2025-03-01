import 'package:dart_calculator/index.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([Lexer, Parser])
import 'dart_calculator_test.mocks.dart';

void main() {
  group("Lexer tests", () {
    void testLexer(String text, Token expected) {
      var lexer = Lexer(text: " + ");
      var token = lexer.nextToken();
      expect(token.type, TokenType.PLUS);
      expect(token.value, '+');
    }

    test('Plus', () {
      testLexer(" + ", Token(type: TokenType.PLUS, value: '+'));
    });
    test('Minus', () {
      testLexer(" - ", Token(type: TokenType.MINUS, value: '-'));
    });
    test('Mul', () {
      testLexer(" * ", Token(type: TokenType.MUL, value: '*'));
    });
    test('Div', () {
      testLexer(" / ", Token(type: TokenType.DIV, value: '/'));
    });
    test('LPAREN', () {
      testLexer(" ( ", Token(type: TokenType.LPAREN, value: '('));
    });
    test('RPAREN', () {
      testLexer(" ) ", Token(type: TokenType.RPAREN, value: ')'));
    });
    test('Integer', () {
      testLexer(" 123 ", Token(type: TokenType.NUMBER, value: '123'));
    });
    test('REAL', () {
      testLexer(" 1.23 ", Token(type: TokenType.NUMBER, value: '1.23'));
    });
    test('Error', () {
      var lexer = Lexer(text: ' abc ');
      expect(() => lexer.nextToken(), throwsA(isA<LexerException>()));
    });
    test('EOF', () {
      testLexer("  ", Token(type: TokenType.EOF, value: 'EOF'));
    });
  });

  group('Parser tests', () {
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
      test('parse integer', () {
        var parser = MockParser();
        when(parser.parse()).thenReturn(IntegerNode(value: 1));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        expect(num, equals(1));
      });

      test('parse real', () {
        var parser = MockParser();
        when(parser.parse()).thenReturn(RealNode(value: 1.1));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        expect(num, equals(1.1));
      });

      test('parse unary -> plus integer', () {
        var parser = MockParser();
        when(parser.parse()).thenReturn(
            UnaryNode(operator: Operator.PLUS, right: IntegerNode(value: 2)));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        expect(num, equals(2));
      });

      test('parse unary -> minus real', () {
        var parser = MockParser();
        when(parser.parse()).thenReturn(
            UnaryNode(operator: Operator.MINUS, right: RealNode(value: 2.0)));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        expect(num, equals(-2.0));
      });

      test('parse binary -> plus integers', () {
        var parser = MockParser();
        when(parser.parse()).thenReturn(BinaryNode(
            left: IntegerNode(value: 1),
            operator: Operator.PLUS,
            right: IntegerNode(value: 2)));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        expect(num, equals(3));
      });

      test('parse binary -> minus integers', () {
        var parser = MockParser();
        when(parser.parse()).thenReturn(BinaryNode(
            left: IntegerNode(value: 1),
            operator: Operator.MINUS,
            right: IntegerNode(value: 2)));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        expect(num, equals(-1));
      });

      test('parse binary -> mul integers', () {
        var parser = MockParser();
        when(parser.parse()).thenReturn(BinaryNode(
            left: IntegerNode(value: 2),
            operator: Operator.MUL,
            right: IntegerNode(value: 1)));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        expect(num, equals(2));
      });

      test('parse binary -> div integers', () {
        var parser = MockParser();
        when(parser.parse()).thenReturn(BinaryNode(
            left: IntegerNode(value: 2),
            operator: Operator.DIV,
            right: IntegerNode(value: 1)));
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        expect(num, equals(2));
      });
    });
  });

  group('Interpreter tests', () {
    void testInterpreter(String text, num expected) {
      var lexer = Lexer(text: text);
      var parser = Parser(lexer: lexer);
      var node = parser.parse();
      var interpreter = Interpreter();
      var num = interpreter.interpret(node);
      expect(num, equals(expected));
    }

    test('interpret integer', () {
      testInterpreter("0", 0);
      testInterpreter("1", 1);
      testInterpreter("-1", -1);
    });
    test('interpret float', () {
      testInterpreter("0.0", 0.0);
      testInterpreter("1.0", 1.0);
      testInterpreter("-1.0", -1.0);
    });
    test('interpret plus', () {
      testInterpreter("1 + 2", 3);
      testInterpreter("1 + 2 + 3", 6);
      testInterpreter("1.0 + 2.0", 3.0);
      testInterpreter("1 + 2.0", 3.0);
      testInterpreter("-1 + -2", -3);
      testInterpreter("-1.0 + -2", -3.0);
    });
    test('interpret minus', () {
      testInterpreter("3 - 2", 1);
      testInterpreter("3 - 2 - 1", 0);
      testInterpreter("-1 - -2", 1);
    });
    test('interpret multiply', () {
      testInterpreter("2 * 3", 6);
      testInterpreter("-2 * 3", -6);
      testInterpreter("2 * 3 * 4", 24);
      testInterpreter("2.0 * 3 * 4", 24.0);
    });
    test('interpret divide', () {
      testInterpreter("6 / 3", 2.0);
      testInterpreter("6 / 3 / 2", 1.0);
    });
    test('interpret preference', () {
      testInterpreter("1 + 2 * 3", 7);
      testInterpreter("1 + 2 * 3 + 4", 11);
      testInterpreter("1 + 2 * 3 - 2", 5);
    });
    test('interpret paren', () {
      testInterpreter("(1 + 2) * (2 + 3)", 15);
      testInterpreter("(-2) * (-3)", 6);
      testInterpreter("(3 + 3) / (2 + 2)", 1.5);
    });
  });
}
