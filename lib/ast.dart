import 'token.dart';

abstract class Node {}

enum NumberType { Real, Integer }



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
