// Mocks generated by Mockito 5.4.4 from annotations
// in dart_calculator/test/dart_calculator_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dart_calculator/index.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeToken_0 extends _i1.SmartFake implements _i2.Token {
  _FakeToken_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeNode_1 extends _i1.SmartFake implements _i2.Node {
  _FakeNode_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [Lexer].
///
/// See the documentation for Mockito's code generation for more information.
class MockLexer extends _i1.Mock implements _i2.Lexer {
  MockLexer() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Token nextToken() => (super.noSuchMethod(
        Invocation.method(
          #nextToken,
          [],
        ),
        returnValue: _FakeToken_0(
          this,
          Invocation.method(
            #nextToken,
            [],
          ),
        ),
      ) as _i2.Token);
}

/// A class which mocks [Parser].
///
/// See the documentation for Mockito's code generation for more information.
class MockParser extends _i1.Mock implements _i2.Parser {
  MockParser() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Node parse() => (super.noSuchMethod(
        Invocation.method(
          #parse,
          [],
        ),
        returnValue: _FakeNode_1(
          this,
          Invocation.method(
            #parse,
            [],
          ),
        ),
      ) as _i2.Node);
}
