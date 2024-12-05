import 'package:dart_calculator/dart_calculator.dart';

import 'dart:io';

void main() {
  try {
    for (;;) {
      stdout.write('\x1B[32mcalc> \x1B[0m');
      String? text = stdin.readLineSync();

      if (text != null) {
        if (text == "exit(0)") {
          break;
        }
        var lexer = Lexer(text: text);
        var parser = Parser(lexer: lexer);
        var node = parser.parse();
        var interpreter = Interpreter();
        var num = interpreter.interpret(node);
        print(num);
      } else {
        print('No text entered.');
      }
    }
  } catch (e) {
    stdout.write('\x1B[31m');

    // Print the error message
    print(e);

    // Reset the color to default
    stdout.write('\x1B[0m');
  }
}
