import 'ast.dart';
import 'exception.dart';
import 'token.dart';

abstract interface class Visitor<T> {
  // ignore: unused_element
  T _visitIntegerNode(IntegerNode node);

  // ignore: unused_element
  T _visitRealNode(RealNode node);

  // ignore: unused_element
  T _visitBinaryNode(BinaryNode node);

  // ignore: unused_element
  T _visitUnaryNode(UnaryNode node);
}

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
