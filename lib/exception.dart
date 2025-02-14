class UnknownException implements Exception {}

class LexerException extends FormatException {
  LexerException({required message}) : super(message);
}

class ParserException implements Exception {
  final String message;

  ParserException(this.message);
}

class InterpreterException implements Exception {}